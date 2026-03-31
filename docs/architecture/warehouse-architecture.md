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
- diagram: `docs/diagrams/industry labor impact bankruptcies.png`
- use case: `docs/use-cases/bankruptcy-risk-hotspots.md`
- star schema: `docs/architecture/star-schema-bankruptcy-hotspots.md`
- star schema: `docs/architecture/star-schema-industry-labor-impact-bankruptcies.md`
- top-level project overview: `README.md`

## Gold Models By Use Case

- `fact_finland_economic_health`
  - grain: `year`
  - purpose: national yearly trend view of bankruptcies, establishments, personnel, population, and deaths
- `fact_bankruptcy_risk_hotspots`
  - grain: `year x municipality`
  - purpose: identify municipalities with the highest bankruptcy pressure relative to their business base; implemented as a stricter star with a derived top-industry foreign key
- `fact_municipality_resilience`
  - grain: `year x municipality`
  - purpose: combine population, establishment, personnel, and bankruptcy signals into a resilience view
- `fact_industry_labor_impact_bankruptcies`
  - grain: `year x municipality x industry`
  - purpose: identify where bankruptcies affect the largest number of employees and support both within-year ranking and cross-year trend analysis

## Industry Labor Impact Model In Context

`fact_industry_labor_impact_bankruptcies` is the most detailed gold fact in the warehouse.

It sits below municipality-level models in grain and is designed for:

- national industry ranking
- municipality-industry drilldowns
- employee impact trend analysis
- classification of labor impact severity

Because it is at `year x municipality x industry` grain, it should not be joined directly to municipality-level facts for reporting without first aggregating to a common grain.