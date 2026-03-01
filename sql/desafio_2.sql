-- DESAFIO 2
-- Objetivo:
-- Ranking dos 10 sellers com maior crescimento de GMV entre o trimestre atual e o anterior,
-- considerando apenas sellers com pelo menos 50 pedidos em ambos os trimestres.
-- Considerar apenas pedidos com status 'completed' ou 'delivered'.

WITH ref AS (
  -- 1) Define uma "data de referência" baseada na maior data real de pedidos válidos.
  --    Isso evita depender da data atual do sistema e deixa o resultado consistente
  --    mesmo se a base estiver desatualizada.
  --
  -- Tuning:
  --   Índice recomendado em orders(status, created_at) para acelerar o MAX() e os filtros por data.
  SELECT DATE(MAX(created_at)) AS ref_date
  FROM orders
  WHERE status IN ('completed', 'delivered')
),

bounds AS (
  -- 2) Calcula o início do trimestre atual (q_curr_start) a partir da ref_date.
  --    A lógica:
  --      - pega o início do mês ('start of month')
  --      - subtrai 0, 1 ou 2 meses para "voltar" até o primeiro mês do trimestre
  --        usando: (mes - 1) % 3
  --
  -- Observação:
  --   Isso funciona bem no SQLite, mas é um trecho “mais difícil de ler”.
  --   Em entrevistas, vale comentar com exemplo (ref_date em fevereiro -> volta 1 mês -> janeiro).
  SELECT
    DATE(
      ref_date,
      'start of month',
      printf('-%d months', (CAST(strftime('%m', ref_date) AS INTEGER) - 1) % 3)
    ) AS q_curr_start
  FROM ref
),

quarters AS (
  -- 3) Deriva as janelas fechadas-abertas (>= start e < end) dos trimestres:
  --    - trimestre atual: [q_curr_start, q_curr_end)
  --    - trimestre anterior: [q_prev_start, q_prev_end) onde q_prev_end = q_curr_start
  --
  -- Tuning:
  --   Usar range com < end evita problemas com horários e melhora o uso de índice em created_at.
  SELECT
    q_curr_start,
    DATE(q_curr_start, '+3 months') AS q_curr_end,
    DATE(q_curr_start, '-3 months') AS q_prev_start,
    q_curr_start AS q_prev_end
  FROM bounds
),

prev AS (
  -- 4) Agrega o trimestre anterior por seller:
  --    - pedidos_prev: contagem de pedidos distintos
  --    - gmv_prev: soma do total_value
  --
  -- Tuning:
  --   O filtro de status e data é aplicado antes do GROUP BY (reduz linhas cedo).
  --   CROSS JOIN quarters é seguro porque quarters tem 1 linha.
  SELECT
    o.seller_id,
    COUNT(DISTINCT o.id) AS pedidos_prev,
    SUM(o.total_value) AS gmv_prev
  FROM orders o
  CROSS JOIN quarters q
  WHERE o.status IN ('completed', 'delivered')
    AND o.created_at >= q.q_prev_start
    AND o.created_at <  q.q_prev_end
  GROUP BY o.seller_id
),

curr AS (
  -- 5) Agrega o trimestre atual por seller (mesma lógica do anterior).
  --    Mantém simetria e legibilidade (bom para manutenção).
  SELECT
    o.seller_id,
    COUNT(DISTINCT o.id) AS pedidos_curr,
    SUM(o.total_value) AS gmv_curr
  FROM orders o
  CROSS JOIN quarters q
  WHERE o.status IN ('completed', 'delivered')
    AND o.created_at >= q.q_curr_start
    AND o.created_at <  q.q_curr_end
  GROUP BY o.seller_id
),

joined AS (
  -- 6) Junta prev e curr (apenas sellers presentes nos dois trimestres).
  --    Junta também sellers para pegar nome/estado.
  --    Aplica o filtro de qualidade: >= 50 pedidos em ambos trimestres.
  --
  -- Crescimento:
  --   (gmv_curr - gmv_prev) / gmv_prev
  --   NULLIF evita divisão por zero (seller com gmv_prev = 0).
  --
  -- Observação de negócio:
  --   Se gmv_prev = 0 e gmv_curr > 0, crescimento seria “infinito”.
  --   Aqui vira NULL e naturalmente fica no fim do ranking (ou some, dependendo do ORDER).
  SELECT
    s.name AS seller_nome,
    s.state AS seller_estado,
    p.gmv_prev,
    c.gmv_curr,
    p.pedidos_prev,
    c.pedidos_curr,
    (c.gmv_curr - p.gmv_prev) / NULLIF(p.gmv_prev, 0) AS crescimento_pct
  FROM prev p
  JOIN curr c ON c.seller_id = p.seller_id
  JOIN sellers s ON s.id = p.seller_id
  WHERE p.pedidos_prev >= 50
    AND c.pedidos_curr >= 50
)

-- 7) Seleciona o top 10 por crescimento, formatando valores.
SELECT
  seller_nome,
  seller_estado,
  ROUND(gmv_prev, 2) AS gmv_trimestre_anterior,
  ROUND(gmv_curr, 2) AS gmv_trimestre_atual,
  ROUND(crescimento_pct * 100.0, 2) AS crescimento_percentual
FROM joined
ORDER BY crescimento_pct DESC
LIMIT 10;
