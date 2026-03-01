# marketplace-b2b-data-pipeline

Repositório com a resolução do **Teste Técnico – Engenharia de Dados**: pipeline de preparação de dados + desafios SQL.

## Estrutura
- `notebooks/01_pipeline_preparacao_dados.ipynb`: pipeline (leitura dos CSVs, padronização de tipos, controles de qualidade e preparação para consultas).
- `notebooks/02_resolucao_desafios_sql.ipynb`: resolução dos desafios SQL (com comentários, tuning e validações).
- `sql/`: queries finais separadas por desafio.
- `data/raw` e `data/processed`: pastas opcionais para insumos e saídas do pipeline.

## Tabelas (datasets)
`orders`, `order_items`, `products`, `sellers`, `buyers`, `payments`.

## Como executar (Local)
```bash
python -m venv .venv
# linux/mac
source .venv/bin/activate
# windows
# .venv\Scripts\activate

pip install -r requirements.txt
jupyter notebook
```

Execute nesta ordem:
1. `notebooks/01_pipeline_preparacao_dados.ipynb`
2. `notebooks/02_resolucao_desafios_sql.ipynb`

## Como executar (Colab)
Abra os notebooks na ordem acima e ajuste o caminho dos CSVs (pasta `data/`).

## Queries finais
As queries finais estão em:
- `sql/desafio_1.sql`
- `sql/desafio_2.sql`
- `sql/desafio_3.sql`
- `sql/desafio_4.sql`
