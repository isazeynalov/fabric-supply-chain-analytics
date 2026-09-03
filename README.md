# Fabric End-to-End Supply Chain Analytics

An end-to-end analytics engineering project built on **Microsoft Fabric**, demonstrating the full medallion architecture (Bronze → Silver → Gold) using Lakehouse, Dataflow Gen2, Warehouse, and Direct Lake connectivity to Power BI.

## Dataset

[DataCo Smart Supply Chain Dataset](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) — ~180,000 order-line records covering orders, shipping, customers, and products across global markets.

## Architecture

```
CSV (DataCo Supply Chain, 180K rows)
        │
        ▼
┌─────────────────────┐
│  Lakehouse (Bronze)  │  Raw CSV ingested and converted to a Delta table
└──────────┬───────────┘
           ▼
┌─────────────────────┐
│  Dataflow Gen2        │  Power Query-based cleaning: removed PII/redundant
│  (Silver)             │  columns, fixed data types, validated column quality
└──────────┬───────────┘
           ▼
┌─────────────────────┐
│  Warehouse (Gold)     │  Star schema built with T-SQL:
│                        │  fct_orders + dim_customer, dim_product,
│                        │  dim_geography, dim_date
└──────────┬───────────┘
           ▼
┌─────────────────────┐
│  Direct Lake           │  Semantic model reading directly from the
│  Semantic Model        │  Warehouse — no data import/duplication
└──────────┬───────────┘
           ▼
┌─────────────────────┐
│  Power BI Dashboard   │  KPI cards, monthly sales trend, late delivery
│                        │  rate by country, sales by category, slicers
└───────────────────────┘
```

## What each layer does

**Bronze (Lakehouse):** Raw CSV loaded into Fabric via Files → Tables, preserving the original data as a Delta table.

**Silver (Dataflow Gen2):** Removed personally identifiable and redundant columns (customer email/password, product images, zip codes), converted date columns to proper Date/Time types, and used column quality/profiling (on the full 180K-row dataset, not just a sample) to validate completeness before publishing to a new `clean_orders` table.

**Gold (Warehouse):** Designed and built a star schema with T-SQL — one fact table (`fct_orders`, 180,519 rows) and four dimension tables (`dim_customer`: 43,816 rows, `dim_product`: 118 rows, `dim_geography`: 3,772 rows, `dim_date`: 1,127 rows) — using cross-database queries from the Warehouse against the Lakehouse.

**Direct Lake:** Built a semantic model directly on the Warehouse (Direct Lake on SQL), manually defining relationships between the fact and dimension tables, avoiding a traditional Import-mode data duplication step.

**Reporting:** Power BI dashboard with KPI cards (Total Sales, Total Profit, Total Orders, Late Delivery Rate), a monthly sales trend line chart, a late delivery rate by country bar chart (filtered to top-10 countries by order volume to avoid small-sample distortion), a sales-by-category breakdown, and Region/Category/Year slicers.

## Screenshots

- `dashboard.png` — final Power BI dashboard
- `model_diagram.png` — semantic model relationships (star schema)
- `lakehouse_tables.png` — Lakehouse bronze/silver tables

## SQL

See [`warehouse_schema.sql`](./warehouse_schema.sql) for the full T-SQL used to build the star schema (dimension and fact table creation + population).

## Skills demonstrated

- Medallion architecture (Bronze/Silver/Gold) in Microsoft Fabric
- Lakehouse ingestion and Delta table management
- Dataflow Gen2 (Power Query) data cleaning and column profiling
- Star schema design and T-SQL (cross-database queries, fact/dimension modeling)
- Direct Lake semantic modeling (no data duplication)
- Power BI dashboard design with slicers and filtered visuals
