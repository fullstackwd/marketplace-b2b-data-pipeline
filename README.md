# Teste Técnico – Engenheiro(a) de Dados (SQL + Pipeline)

Repositório com a resolução do **Desafio Técnico - Engenharia de Dados** (marketplace B2B), contendo:
- **Pipeline de preparação de dados** (leitura dos CSVs, validações e persistência em SQLite)
- **Resolução dos desafios SQL (1 a 4)** dentro do notebook, com queries e explicações (incluindo raciocínio do Desafio 3)

---

## Estrutura do projeto

```md
.
├── notebooks/
│   ├── 01_pipeline_preparacao_dados.ipynb
│   └── 02_resolucao_desafios_sql.ipynb
├── data/
│   ├── raw/                  # (opcional) CSVs de entrada
│   └── processed/
│       └── pipeline.db       # gerado pelo pipeline
├── requirements.txt
└── README.md
```


> Observação: os notebooks suportam **fallback para `/mnt/data`** (útil em ambiente de avaliação/Colab).

---

## Dados de entrada

Arquivos esperados:
- `orders.csv`
- `order_items.csv`
- `products.csv`
- `sellers.csv`
- `buyers.csv`
- `payments.csv`

Onde colocar:
1. **Opção A (local/repo):** `./data/raw/`
2. **Opção B (fallback):** `/mnt/data/`

---

## Como rodar (passo a passo)

### 1) Criar ambiente e instalar dependências

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
source .venv/bin/activate

pip install -r requirements.txt
2) Executar o pipeline (gera o banco SQLite)

Abra e rode:

notebooks/01_pipeline_preparacao_dados.ipynb

Saída:

data/processed/pipeline.db (SQLite)

3) Rodar as soluções SQL

Abra e rode:

notebooks/02_resolucao_desafios_sql.ipynb

Esse notebook conecta no pipeline.db e executa as queries de:

Desafio 1: faturamento bruto mensal (últimos 12 meses), nº pedidos e ticket médio

Desafio 2: top 10 sellers por crescimento de GMV (tri atual vs tri anterior) com filtro de 50+ pedidos em ambos

Desafio 3: pedidos com desconto total > 40% do valor bruto (exclui cancelados) + explicação do raciocínio

Desafio 4: produtos com unidades vendidas > 1000 que nunca foram o item de maior valor unitário no pedido (window functions)

Dependências

requirements.txt sugerido:

pandas>=2.0
numpy>=1.24
matplotlib>=3.7
SQLAlchemy>=2.0
jupyter>=1.0
Assunções e decisões (importante para avaliação)

Pedidos válidos para métricas de vendas (Desafios 1 e 2): somente status IN ('completed', 'delivered').

Pedidos excluídos (Desafios 3 e 4): status NOT IN ('cancelled', 'refunded').

Últimos 12 meses (Desafio 1): janela baseada na maior data disponível no dataset (ref_date) para reprodutibilidade.

Trimestre atual/anterior (Desafio 2): calculado com base em ref_date (maior created_at disponível), evitando dependência de “data de hoje”.

GMV (Desafio 2): soma de orders.total_value para pedidos válidos.

Crescimento percentual: protegido contra divisão por zero via NULLIF(...).

Desafio 4: avaliação feita por unit_price (valor unitário). Em caso de empate do maior valor unitário no pedido, o empate conta como “apareceu como maior” (explicado no notebook).

Onde encontrar as respostas

Pipeline:

notebooks/01_pipeline_preparacao_dados.ipynb

SQL + explicações:

notebooks/02_resolucao_desafios_sql.ipynb

Observações de qualidade

Tratamento de NULL e tipos (IDs como string para evitar problemas de join/casting)

Prevenção de divisão por zero em métricas percentuais (NULLIF)

Filtros aplicados antes de agregações para reduzir cardinalidade

Uso de CTEs e window functions quando apropriado (especialmente no Desafio 4)