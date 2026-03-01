-- DESAFIO 3
-- Objetivo:
-- Encontrar pedidos onde o desconto total (soma dos descontos dos itens)
-- representa mais de 40% do valor bruto do pedido.
-- Listar também seller responsável e a data do pedido.
-- Excluir pedidos cancelados.

WITH itens AS (
  -- 1) Agrega por pedido (order_id) os valores necessários vindos de order_items.
  --    - valor_bruto: soma de qty * unit_price (valor "cheio" antes de desconto)
  --    - desconto_total: soma dos descontos (COALESCE garante que NULL vira 0)
  --
  -- Tuning:
  --   Fazer essa agregação primeiro reduz cardinalidade (muitos itens -> 1 linha por pedido),
  --   deixando o JOIN com orders muito mais barato.
  SELECT
    oi.order_id,
    SUM(oi.qty * oi.unit_price) AS valor_bruto,
    SUM(COALESCE(oi.discount, 0)) AS desconto_total
  FROM order_items oi
  GROUP BY oi.order_id
),

base AS (
  -- 2) Junta os agregados de itens com a tabela de pedidos (orders)
  --    e calcula o percentual de desconto.
  --
  -- Exclui pedidos com status 'cancelled' e 'refunded' (conforme enunciado).
  --
  -- Boas práticas:
  --   NULLIF(valor_bruto, 0) evita divisão por zero se algum pedido tiver valor bruto 0
  --   (ex.: qty=0, item grátis, dado inconsistente etc.)
  --
  -- Atenção (tuning):
  --   DATE(o.created_at) é apenas para exibição (SELECT), não está no WHERE, então não atrapalha índice.
  --   Se você filtrasse por data no WHERE, o ideal seria usar range (>= e <) sem DATE().
  SELECT
    o.id AS order_id,
    o.seller_id,
    DATE(o.created_at) AS data_pedido,
    i.valor_bruto,
    i.desconto_total,
    (i.desconto_total / NULLIF(i.valor_bruto, 0)) AS perc_desconto
  FROM orders o
  JOIN itens i ON i.order_id = o.id
  WHERE o.status NOT IN ('cancelled', 'refunded')
)

-- 3) Enriquecimento final com dados do seller e filtro de regra de fraude (>40%).
--    Ordena pelos maiores percentuais de desconto (mais suspeitos) e, em caso de empate,
--    mostra pedidos mais recentes primeiro.
SELECT
  b.order_id,
  s.name AS seller_nome,
  s.state AS seller_estado,
  b.data_pedido,
  ROUND(b.valor_bruto, 2) AS valor_bruto,
  ROUND(b.desconto_total, 2) AS desconto_total,
  ROUND(b.perc_desconto * 100.0, 2) AS perc_desconto
FROM base b
JOIN sellers s ON s.id = b.seller_id
WHERE b.perc_desconto > 0.40
ORDER BY b.perc_desconto DESC, b.data_pedido DESC;
