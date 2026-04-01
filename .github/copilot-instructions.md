# Project Guidelines

## Overview

This is a Finnish municipal analytics warehouse (Solita Data Academy Spring 2026). It transforms Statistics Finland public data into business-ready gold models for Databricks Genie dashboards and AI-assisted analysis.

## Architecture

- **Medallion layers**: raw → bronze → silver → gold
- **Raw**: CSV extracts from Statistics Finland API in `data/raw/`
- **Bronze**: Delta tables ingested via Databricks notebook (`databricks/notebooks/ingest_bronze.ipynb`)
- **Silver**: dbt models in `dbt/models/silver/` — standardize names, types, filter non-analytic rows
- **Gold**: dbt models in `dbt/models/gold/` — star-schema dimensional models with business logic
- **Orchestration**: Azure Data Factory triggers in `adf/trigger_json.json`
- **Config**: StatFin API query definitions in `config/stat_source_files.json`

## Dimensional Modeling Rules

These are strict — follow them in every gold model:

1. **Separate fact tables per grain** — never merge different grains into one fact
2. **Never join facts of different grain directly** — create a gold model at the reporting grain instead
3. **Stable dimension keys** — `dim_year` uses natural key (`year_id = year`); `dim_municipality` and `dim_industry` use deterministic hash keys from names. Never use `row_number()`
4. **Handle `industry = 'Total'` carefully** — use it for municipality/national totals; never sum detail rows with Total rows
5. **Exclude `Total` and `Industry unknown`** from top-industry logic
6. **Foreign keys + measures only** in fact tables — descriptive labels belong in dimensions

## Shared Dimensions

| Dimension | Key | Source |
|-----------|-----|--------|
| `dim_year` | `year_id = year` | Natural key |
| `dim_municipality` | `municipality_id` | `md5(municipality_name)` |
| `dim_industry` | `industry_id` | `md5(industry_name)` |

## dbt Conventions

- **Profile**: `andreas_statfin` (Databricks)
- **Schemas**: `andreas_statfin_silver`, `andreas_statfin_gold`
- **Silver SQL pattern**: `with source as (...), renamed as (...) select * from renamed`
- **Gold SQL pattern**: CTE aliases (`b`, `dim_m`, `dim_i`, `dim_y`), left joins to dimensions
- **Materialization**: all models are `table`
- **Naming**: `silver_statfin_<source>.sql`, `fact_<use_case>.sql`, `dim_<entity>.sql`
- **Custom macro**: `generate_schema_name.sql` controls schema routing

## Documentation Conventions

- **Use-case docs** (`docs/use-cases/`): Business Question → Value → Gold Model → Dimensions → Metrics → Genie Questions
- **Star-schema docs** (`docs/architecture/star-schema-*.md`): Fact Table → Dimensions → Why Star Schema → Diagram ref
- **DBML diagrams** (`docs/diagrams/*.dbml`): Table definitions with PKs, FKs, indexes, and Ref lines
- **Architecture docs** (`docs/architecture/`): Explain modeling decisions and structure

## Key Files

- `README.md` — project overview
- `dbt/dbt_project.yml` — dbt configuration
- `dbt/profiles.yml` — Databricks connection
- `docs/architecture/modeling-decisions.md` — why the gold layer is shaped this way
- `docs/architecture/warehouse-architecture.md` — layer descriptions and model inventory
