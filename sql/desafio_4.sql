WITH valid_items AS (
  -- Base “limpa”: itens de pedidos válidos (exclui cancelados e reembolsados).
  -- Mantém apenas colunas necessárias para reduzir custo.
  SELECT
    oi.order_id,
    oi.product_id,
    oi.qty,
    oi.unit_price
  FROM order_items oi
  JOIN orders o
    ON o.id = oi.order_id
   AND o.status NOT IN ('cancelled', 'refunded')
),

sold AS (
  -- Soma unidades vendidas por produto.
  -- HAVING filtra só produtos que passaram do MIN_UNITS.
  SELECT
    product_id,
    SUM(qty) AS units_sold
  FROM valid_items
  GROUP BY product_id
  HAVING SUM(qty) > {MIN_UNITS}
),

prod_orders AS (
  -- Conta em quantos pedidos distintos cada produto apareceu.
  -- É o denominador para calcular a % de vezes que foi “o mais caro”.
  SELECT
    product_id,
    COUNT(DISTINCT order_id) AS n_orders
  FROM valid_items
  GROUP BY product_id
),

prod_orders_as_max AS (
  -- Conta em quantos pedidos cada produto foi o item de MAIOR unit_price.
  -- 1) Subquery m calcula o max_unit_price por pedido.
  -- 2) Junta com valid_items para pegar quais produtos têm unit_price == max_unit_price.
  -- Observação: se houver empate (dois itens com mesmo unit_price máximo),
  -- ambos contam para n_orders_as_max.
  SELECT
    vi.product_id,
    COUNT(DISTINCT vi.order_id) AS n_orders_as_max
  FROM valid_items vi
  JOIN (
    SELECT
      order_id,
      MAX(unit_price) AS max_unit_price
    FROM valid_items
    GROUP BY order_id
  ) m
    ON m.order_id = vi.order_id
   AND vi.unit_price = m.max_unit_price
  GROUP BY vi.product_id
)

-- Seleção final: traz dados do produto e métricas calculadas
SELECT
  p.id        AS product_id,
  p.name      AS product_nome,
  p.category  AS categoria,
  s.units_sold,
  po.n_orders,
  COALESCE(pm.n_orders_as_max, 0) AS n_orders_as_max,

  -- Percentual de pedidos em que o produto foi o item mais caro.
  -- Multiplica por 1.0 para forçar divisão em float (evita divisão inteira).
  (COALESCE(pm.n_orders_as_max, 0) * 1.0 / po.n_orders) AS pct_orders_as_max
FROM sold s
JOIN prod_orders po
  ON po.product_id = s.product_id
LEFT JOIN prod_orders_as_max pm
  ON pm.product_id = s.product_id
JOIN products p
  ON p.id = s.product_id

-- Filtro principal: mantém apenas produtos cuja % de “mais caro” é <= MAX_PCT_TOP
WHERE (COALESCE(pm.n_orders_as_max, 0) * 1.0 / po.n_orders) <= {MAX_PCT_TOP}

-- Ordena pelos mais vendidos (entre os que passaram nos filtros)
ORDER BY s.units_sold DESC;
