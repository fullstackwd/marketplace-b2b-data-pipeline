````md
# Teste Técnico – Engenheiro(a) de Dados (SQL + Pipeline)

Repositório com a resolução do **Desafio Técnico - Engenharia de Dados** (marketplace B2B), contendo:
- **Pipeline de preparação de dados** (leitura dos CSVs, validações e persistência em SQLite) no arquivo `notebooks/01_pipeline_preparacao_dados.ipynb`.
- **Resolução dos desafios SQL (1 a 4)** com queries e explicações no arquivo `notebooks/02_resolucao_desafios_sql.ipynb`.

---

## Estrutura do projeto

```text
.
├── notebooks/
│   ├── 01_pipeline_preparacao_dados.ipynb
│   └── 02_resolucao_desafios_sql.ipynb
├── data/
│   ├── raw/
│   │   ├── buyers.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   ├── payments.csv
│   │   ├── products.csv
│   │   └── sellers.csv
│   └── processed/
│       └── pipeline.db
├── outputs/
│   ├── figures/
│   ├── logs/
│   └── tables/
├── requirements.txt
└── README.md
````

> Observação: a pasta `.ipynb_checkpoints/` não faz parte do projeto e deve ser ignorada via `.gitignore`.

---

## Dados de entrada

Arquivos esperados em `data/raw/`:

* `orders.csv`
* `order_items.csv`
* `products.csv`
* `sellers.csv`
* `buyers.csv`
* `payments.csv`

---

## Quickstart

### 1) Criar ambiente e instalar dependências

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# Mac/Linux:
source .venv/bin/activate

pip install -U pip
pip install -r requirements.txt
```

### 2) Executar o pipeline (gera o banco SQLite)

Abra e rode o notebook:

* `notebooks/01_pipeline_preparacao_dados.ipynb`

**Entradas:** `data/raw/*.csv`
**Saída:** `data/processed/pipeline.db` (SQLite)

### 3) Rodar as soluções SQL

Abra e rode:

* `notebooks/02_resolucao_desafios_sql.ipynb`

Esse notebook conecta em `data/processed/pipeline.db` e executa as queries dos desafios 1 a 4.

---

## Instruções detalhadas (Jupyter / Colab / VS Code)

### 1) Jupyter Notebook / JupyterLab (no seu PC)

#### Instalar (recomendado: ambiente virtual)

**Windows (PowerShell)**

```bash
py -m venv .venv
.\.venv\Scripts\activate
pip install -U pip
pip install -r requirements.txt
```

**Mac/Linux**

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

#### Abrir e rodar

1. No terminal, entre na pasta do projeto:

```bash
cd caminho/do/seu/projeto
```

2. Rode:

```bash
jupyter lab
```

(ou `jupyter notebook`)

3. Abra e execute na ordem:

* `notebooks/01_pipeline_preparacao_dados.ipynb`
* `notebooks/02_resolucao_desafios_sql.ipynb`

#### Dica pra não quebrar caminho

* Os CSVs devem estar em `data/raw/`.
* Use sempre caminho relativo no notebook, por exemplo:

```python
import pandas as pd
orders = pd.read_csv("data/raw/orders.csv")
```

---

### 2) Google Colab (na nuvem)

> Observação: no Colab, o diretório padrão é `/content`. Para evitar “arquivo não encontrado”, o mais simples é manter a mesma estrutura `data/raw/`.

#### Opção A — Upload manual (mais simples)

1. Abra o Colab e faça upload do notebook (`.ipynb`).
2. No menu esquerdo: **Files (Arquivos)** → **Upload**.
3. Crie as pastas `data/raw/` (se não existirem) e envie todos os CSVs para `data/raw/`.
4. Execute os notebooks normalmente.

Exemplo para criar diretórios:

```python
import os
os.makedirs("data/raw", exist_ok=True)
os.makedirs("data/processed", exist_ok=True)
```

#### Opção B — Montar Google Drive (bom para persistir arquivos)

```python
from google.colab import drive
drive.mount("/content/drive")
```

Sugestão de estrutura no Drive:

* `/content/drive/MyDrive/desafio/data/raw/`

Aí você pode:

* (1) **copiar** os CSVs para `/content/data/raw/`, ou
* (2) **ajustar** o caminho de leitura no notebook para apontar para o Drive.

#### Instalar dependências no Colab

```bash
!pip install -r requirements.txt
```

---

### 3) VS Code (com Jupyter)

#### Preparar

1. Instale o **VS Code** e o **Python**.
2. No VS Code, instale as extensões:

   * **Python** (Microsoft)
   * **Jupyter** (Microsoft)

#### Criar ambiente virtual (recomendado)

No terminal integrado do VS Code:

**Windows**

```bash
py -m venv .venv
.\.venv\Scripts\activate
pip install -U pip
pip install -r requirements.txt
```

**Mac/Linux**

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

#### Abrir e rodar

1. Abra a pasta do projeto: **File → Open Folder**
2. Abra o notebook `.ipynb`
3. No canto superior direito, selecione o **Kernel** do Python da `.venv`
4. Execute na ordem:

* `notebooks/01_pipeline_preparacao_dados.ipynb`
* `notebooks/02_resolucao_desafios_sql.ipynb`

---

## Padrão “à prova de ambiente” (recomendado)

Coloque todos os CSVs em `data/raw/` e use sempre caminho relativo:

```python
import pandas as pd
orders = pd.read_csv("data/raw/orders.csv")
```

---

## Dependências

`requirements.txt` sugerido:

```txt
pandas>=2.0
numpy>=1.24
matplotlib>=3.7
SQLAlchemy>=2.0
jupyter>=1.0
```

---

## Assunções e decisões (importante para avaliação)

* **Pedidos válidos para métricas de vendas (Desafios 1 e 2):** somente status `IN ('completed', 'delivered')`.
* **Pedidos excluídos (Desafios 3 e 4):** status `NOT IN ('cancelled', 'refunded')`.

  * Nota: além de cancelados, considerei pedidos **estornados** (`refunded`) como não-venda para evitar distorções nas análises de desconto/itens.
* **Últimos 12 meses (Desafio 1):** janela baseada na maior data disponível no dataset (`ref_date`) para reprodutibilidade.
* **Trimestre atual/anterior (Desafio 2):** calculado com base em `ref_date` (maior `created_at` disponível), evitando dependência de “data de hoje”.
* **GMV (Desafio 2):** soma de `orders.total_value` para pedidos válidos.
* **Crescimento percentual:** protegido contra divisão por zero via `NULLIF(...)`.
* **Desafio 4:** avaliação por `unit_price` (valor unitário). Em caso de empate do maior valor unitário no pedido, o empate conta como “apareceu como maior” (explicado no notebook).

---

## Onde encontrar as respostas

* Pipeline: `notebooks/01_pipeline_preparacao_dados.ipynb`
* SQL + explicações: `notebooks/02_resolucao_desafios_sql.ipynb`

---

## Observações de qualidade

* Tratamento de `NULL` e tipos (IDs como string para evitar problemas de join/casting).
* Prevenção de divisão por zero em métricas percentuais (`NULLIF`).
* Filtros aplicados antes de agregações para reduzir cardinalidade.
* Uso de CTEs e window functions quando apropriado (especialmente no Desafio 4).

