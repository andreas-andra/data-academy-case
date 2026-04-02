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

- DBML diagram sources in `docs/diagrams/` are the authoritative schema documentation
- rendered SVG and PNG diagrams exist for every DBML-backed gold fact model
- DBML diagram sources live in `docs/diagrams/`
- fact-level star-schema notes live in `docs/architecture/`
- business-facing use-case docs live in `docs/use-cases/`
- dashboard-specific guidance lives in `docs/genie-dashboards/`
- top-level project overview lives in `README.md`

## Gold Models By Use Case

- `fact_bankruptcies`
  - grain: `year x municipality x industry`
  - purpose: reusable base bankruptcy fact with full industry coverage, including aggregate source rows
- `fact_population`
  - grain: `year x municipality`
  - purpose: reusable municipality denominator fact for population, deaths, establishments, and personnel
- `fact_municipality_overview`
  - grain: `year x municipality`
  - purpose: wide municipality monitoring fact that combines demographic, business-base, and bankruptcy totals
- `fact_finland_economic_health`
  - grain: `year`
  - purpose: national yearly trend view of bankruptcies, establishments, personnel, population, and deaths
- `fact_bankruptcies_by_industry`
  - grain: `year x industry`
  - purpose: national yearly bankruptcy mix by industry with share-of-total context
- `fact_regional_mortality`
  - grain: `year x municipality`
  - purpose: track municipality deaths, death rates, and population change over time
- `fact_bankruptcy_risk_hotspots`
  - grain: `year x municipality`
  - purpose: identify municipalities with the highest bankruptcy pressure relative to their business base; implemented as a stricter star with a derived top-industry foreign key
- `fact_municipality_resilience`
  - grain: `year x municipality`
  - purpose: combine population, establishment, personnel, and bankruptcy signals into a resilience view
- `fact_industry_labor_impact_bankruptcies`
  - grain: `year x municipality x industry`
  - purpose: identify where bankruptcies affect the largest number of employees and support both within-year ranking and cross-year trend analysis
- `fact_industry_bankruptcy_specialization`
  - grain: `year x municipality x industry`
  - purpose: identify industries that are overrepresented in municipal bankruptcies relative to the national industry bankruptcy structure; implemented as a stricter textbook star with shared dimensions only
- `fact_municipality_business_dynamics`
  - grain: `year x municipality`
  - purpose: track municipality-level business base growth and decline over time, combining establishment counts, personnel, and population into density and growth metrics

## Industry Labor Impact Model In Context

`fact_industry_labor_impact_bankruptcies` is the most detailed gold fact in the warehouse.

It sits below municipality-level models in grain and is designed for:

- national industry ranking
- municipality-industry drilldowns
- employee impact trend analysis
- classification of labor impact severity

Because it is at `year x municipality x industry` grain, it should not be joined directly to municipality-level facts for reporting without first aggregating to a common grain.

## Industry Bankruptcy Specialization Model In Context

`fact_industry_bankruptcy_specialization` is another detailed gold fact at `year x municipality x industry` grain.

It is designed for:

- identifying industries that are overrepresented in local bankruptcies relative to the national pattern
- municipality-industry drilldowns into concentrated bankruptcy structure
- cross-year trend analysis of specialization severity
- separating statistically stronger signals from low-volume extreme ratios

The implemented model follows a stricter textbook star shape:

- the fact stores foreign keys and measures only
- municipality, industry, and year labels come from shared dimensions

Because it is at `year x municipality x industry` grain, it should not be joined directly to municipality-level facts for reporting without first aggregating to a common grain.

Dashboard users should also distinguish between:

- supported-only analysis using `specialization_support_class = 'Supported signal'`
- explicit exception views that intentionally include low-support rows, such as support breakdowns or enterprise-vs-employee comparison plots