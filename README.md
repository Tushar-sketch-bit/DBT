# DBT Analytics Project

A modern end-to-end analytics engineering project built with dbt and designed for Snowflake-based warehousing. This repository transforms raw e-commerce operational data into curated, business-ready datasets for customer, seller, and delivery analysis.

## Overview

This project follows a standard ELT pattern:

- Raw source data is stored in Snowflake
- dbt staging models clean and standardize source data
- Intermediate models apply business logic and analytics calculations
- Mart models expose final tables for reporting and dashboarding

The data model is based on an Olist-style e-commerce dataset and includes analysis across:

- Customer behavior and purchase patterns
- Order value and payment analysis
- Seller performance by state
- Delivery and operational performance
- Business benchmarking across regions

## Why this project

This repository is a practical example of a Snowflake + dbt analytics pipeline that showcases:

- Source-to-model lineage using dbt
- Layered transformation design
- Data quality checks and testing
- Analytical modeling for BI consumption
- Clean separation between staging, intermediate, and final marts

## Architecture

```text
Snowflake raw tables (OLIST_ANALYTICS.RAW)
        │
        ▼
   dbt staging models
        │
        ▼
   dbt intermediate models
        │
        ▼
   dbt marts / reporting tables
        │
        ▼
   Power BI / dashboards / analytics consumers
```

## Project Structure

```text
DBT/
├── README.md
├── LICENSE
├── .gitignore
├── dbt_project.yml
├── ingest_to_duckdb.py
├── dbt_project.pbix
├── analyses/
├── macros/
├── models/
│   ├── sources.yml
│   ├── ques.txt
│   ├── staging/
│   │   ├── schema.yml
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   ├── stg_orderpayments.sql
│   │   └── stg_revenue.sql
│   ├── intermediate/
│   │   ├── int_business_metrics.sql
│   │   ├── int_customer_orders.sql
│   │   ├── int_customer_state_behaviour.sql
│   │   ├── int_order_delivery.sql
│   │   ├── int_order_metrics.sql
│   │   ├── int_seller_revenue.sql
│   │   ├── int_seller_state_performance.sql
│   │   ├── int_seller_state_revenue.sql
│   │   └── int_state_delivery_metrics.sql
│   └── marts/
│       ├── schema.yml
│       ├── mart_customer_behaviour.sql
│       ├── mart_delivery_performance.sql
│       └── marts_seller_performance.sql
├── seeds/
├── snapshots/
├── tests/
└── .gitkeep files
```

## Source Data

The project reads from raw Snowflake source tables defined in `models/sources.yml`:

```yaml
version: 2

sources:
  - name: olist
    database: OLIST_ANALYTICS
    schema: RAW
    tables:
      - name: orders
      - name: customers
      - name: orderitems
      - name: products
      - name: sellers
      - name: orderpayments
      - name: orderreviews
      - name: geolocation
      - name: product_category_names
      - name: revenue_table
```

This indicates the base warehouse and schema for the pipeline are structured as:

- Database: `OLIST_ANALYTICS`
- Schema: `RAW`

## dbt Project Configuration

The `dbt_project.yml` file configures the project and default materializations:

```yaml
name: 'analytics_project'
version: '1.0.0'
profile: 'analytics_project'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

models:
  analytics_project:
    staging:
      +materialized: view
    intermediate:
      +materialized: view
    marts:
      +materialized: table
```

Key interpretation:

- `staging` models are materialized as views
- `intermediate` models are also views for flexible reuse
- `marts` models are materialized as tables for reporting and downstream consumption

## Data Model Layers

### 1. Staging layer

Staging models expose clean versions of the raw data without heavy business logic.

Example: `models/staging/stg_orders.sql`

```sql
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM {{ source('olist', 'orders') }}
```

Example: `models/staging/stg_customers.sql`

```sql
select 
customer_id,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state
from {{ source('olist','customers') }}
```

### 2. Intermediate layer

Intermediate models combine related entities and add business logic such as order spend, seller revenue, and customer behavior signals.

Example: `models/intermediate/int_customer_orders.sql`

```sql
with payment_per_order as (
select 
order_id,
sum(payment_value) as order_spend
from {{ ref('stg_orderpayments') }}
group by order_id
)
select
p.order_id,
p.order_spend,
o.customer_id,
o.order_status,
o.order_purchase_timestamp,
c.customer_unique_id,
c.customer_state
from payment_per_order as p

left join {{ ref('stg_orders') }} as o 
on p.order_id = o.order_id

left join {{ ref('stg_customers') }} as c
on o.customer_id = c.customer_id
```

Example: `models/intermediate/int_customer_state_behaviour.sql`

```sql
with t as (select 
customer_unique_id,
customer_state as state,
count(order_id) as order_count,
sum(order_spend) as total_spend,
min(order_purchase_timestamp) as first_purchase_date,
max(order_purchase_timestamp) as last_purchase_date,
from {{ ref('int_customer_orders') }}
group by customer_unique_id, customer_state
),

p as (select *,
avg(order_count) over(partition by state) as state_avg_order_count,
sum(total_spend) over(partition by customer_unique_id) as customer_total_spend 
from t)

select *,
case when order_count> state_avg_order_count then 'Repeat'
when order_count < state_avg_order_count then 'Regular'
else 'Average'
end as customer_activity_type,
DATEDIFF('day',first_purchase_date,last_purchase_date) as customer_lifetime_days,
total_spend *100/ NULLIF(customer_total_spend, 0) as state_spend_share
from p
```

### 3. Mart layer

Final marts are designed for reporting and business-facing analysis.

Example: `models/marts/mart_customer_behaviour.sql`

```sql
select
customer_unique_id,
state,
order_count,
total_spend,
customer_total_spend,
state_spend_share,
first_purchase_date,
last_purchase_date,
customer_lifetime_days,
state_avg_order_count,
customer_activity_type

from {{ ref('int_customer_state_behaviour') }}
```

Example: `models/marts/marts_seller_performance.sql`

```sql
SELECT
    seller_id,
    state,
    revenue,
    state_avg_revenue,
    state_total_revenue,
    state_rank,
    state_contribution_pct,
    diff_from_state_avg,
    performance_status
FROM {{ ref('int_business_metrics') }}
```

## Business Questions This Project Answers

This analytics model enables analysis such as:

- Which customers are the most valuable by state?
- What is the order and spend behavior by customer segment?
- Which sellers outperform the regional average?
- How much revenue is contributed by each state?
- How do order delivery and performance vary geographically?

## Data Quality and Testing

The project includes dbt tests on critical fields to ensure reliability of downstream analytics.

Example from `models/staging/schema.yml`:

```yaml
version: 2

models:
  - name: stg_customers
    description: "Staging model for customers."
    columns:
      - name: customer_id
        tests:
          - not_null

      - name: customer_zip_code_prefix
        tests:
          - not_null

      - name: customer_city
        tests:
          - not_null

      - name: customer_state
        tests:
          - not_null

      - name: customer_unique_id
        tests:
          - not_null
```

This enforces quality checks on essential business keys before analysis is built on top of them.

## Snowflake Setup

This project is intended to run against Snowflake. A typical `profiles.yml` entry would include:

```yaml
analytics_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: your_account
      user: your_user
      password: your_password
      role: your_role
      database: OLIST_ANALYTICS
      warehouse: your_warehouse
      schema: RAW
      threads: 4
      client_session_keepalive: True
```

You would replace the placeholders with your actual Snowflake account, role, database, and warehouse values.

## Getting Started

### Prerequisites

- Python 3.9+
- dbt Core
- dbt Snowflake adapter
- Snowflake access with the required warehouse and schema permissions

### Install dependencies

```bash
pip install dbt-core dbt-snowflake
```

### Validate connection

```bash
dbt debug
```

### Run the project

```bash
dbt run
```

### Run tests

```bash
dbt test
```

### Generate documentation

```bash
dbt docs generate
dbt docs serve
```

## Additional Ingestion Script

The repository also contains a Python ingestion example named `ingest_to_duckdb.py` that uses `dlt` to move data into DuckDB.

```python
import dlt
import requests

# 1. Fetch the data from the API
def fetch_mock_users():
    url = "https://typicode.com"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

# 2. Configure the pipeline
pipeline = dlt.pipeline(
    pipeline_name="local_api_pipeline",
    destination="duckdb",
    dataset_name="raw_staging"
)

# 3. Fire the ingestion
load_info = pipeline.run(
    fetch_mock_users(),
    table_name="api_users",
    credentials="dev.duckdb"
)

print(load_info)
```

This script is a lightweight local ingestion example and complements the dbt warehouse transformation layer.

## Future Enhancements

This project can be extended to include:

- dbt snapshots for historical state tracking
- incremental models for large datasets
- orchestration via Airflow or Dagster
- automated CI/CD validation for dbt runs
- data lineage and governance improvements
- Power BI or Looker dashboards on top of marts

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Summary

This repository demonstrates a complete dbt-driven data analytics workflow in a Snowflake environment. It transforms raw operational data into clean, curated datasets for customer, seller, and delivery intelligence while following a scalable and maintainable analytics engineering pattern.
