# Warehouse Architecture

## Overview

This project uses a layered warehouse design to turn raw Finnish public statistics into business-facing analytics models.

## Layers

### Raw Layer

- Located in `data/raw/`
- Contains source CSV extracts from Statistics Finland
- Keeps the original files available for traceability

### Silver Layer

- Located in `dbt/models/silver/`
- Standardizes column names, data types, and missing values
- Removes obvious non-analytic rows such as `WHOLE COUNTRY` where needed
- Keeps each model close to source grain

### Gold Layer

- Located in `dbt/models/gold/`
- Exposes business-facing facts and shared dimensions
- Applies dimensional modeling and derived business metrics
- Powers Databricks Genie dashboards and other analytics outputs

## Shared Dimensions

- `dim_year`
  - natural key: `year_id = year`
- `dim_municipality`
  - stable hash-based key from municipality name
- `dim_industry`
  - stable hash-based key from industry name

## Why The Gold Layer Matters

The gold layer prevents common analytics errors by enforcing clear grain and reusable business logic.

Examples of modeling problems addressed:

- fan-out joins between facts of different grain
- double-counting from aggregate rows such as `industry = 'Total'`
- unstable keys created with `row_number()`
- business labels that do not match Finnish context

## Current Documentation Assets

- diagram: `docs/diagrams/bankruptcy_risk_hotspots.png`
- use case: `docs/use-cases/bankruptcy-risk-hotspots.md`
- top-level project overview: `README.md`