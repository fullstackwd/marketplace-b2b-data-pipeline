-- DESAFIO 1
-- Objetivo:
-- Calcular o faturamento bruto mensal dos últimos 12 meses
-- considerando apenas pedidos com status 'completed' ou 'delivered'.
-- Também calcular:
--   - quantidade de pedidos
--   - ticket médio
-- Ordenado do mês mais recente para o mais antigo.

WITH ref AS (
  -- 1) Descobre a data máxima de pedido válido.
  --    Em vez de usar CURRENT_DATE, usamos a maior data real da base,
  --    o que torna a análise robusta mesmo se o dataset não estiver atualizado.
  --
  -- Tuning:
  --    Ideal ter índice em (status, created_at) para acelerar esse MAX().
  SELECT
    DATE(MAX(created_at)) AS max_date
  FROM orders
  WHERE status IN ('completed', 'delivered')
),

bounds AS (
  -- 2) Define o intervalo dos últimos 12 meses com base na data máxima.
  --    start_12m = primeiro dia do mês 11 meses antes
  --    end_exclusive = primeiro dia do mês seguinte ao último mês válido
  --
  -- Tuning:
  --    Usar intervalo com >= e < evita problemas de hora/minuto/segundo
  --    e permite melhor uso de índice do que aplicar função no WHERE.
  SELECT
    DATE(max_date, 'start of month', '-11 months') AS start_12m,
    DATE(max_date, 'start of month', '+1 month')  AS end_exclusive
  FROM ref
),

base AS (
  -- 3) Filtra pedidos válidos dentro do intervalo calculado.
  --    Aqui já reduzimos o dataset antes da agregação final.
  --
  -- Tuning importante:
  --    O filtro usa range (created_at >= ... AND created_at < ...)
  --    evitando aplicar DATE(created_at) no WHERE,
  --    o que permite uso de índice em created_at.
  SELECT
    DATE(o.created_at, 'start of month') AS mes, -- usado apenas para agrupamento
    o.id AS order_id,
    o.total_value AS total_value
  FROM orders o
  CROSS JOIN bounds b
  WHERE o.status IN ('completed', 'delivered')
    AND o.created_at >= b.start_12m
    AND o.created_at <  b.end_exclusive
)

-- 4) Agregação final
--    Calcula métricas de negócio:
--      - Faturamento bruto
--      - Quantidade de pedidos
--      - Ticket médio
--
-- Tuning:
--    COUNT(DISTINCT order_id) garante consistência caso haja duplicidade.
--    NULLIF evita divisão por zero.
SELECT
  mes,
  ROUND(SUM(total_value), 2) AS faturamento_bruto,
  COUNT(DISTINCT order_id) AS qtd_pedidos,
  ROUND(SUM(total_value) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS ticket_medio
FROM base
GROUP BY mes
ORDER BY mes DESC;
