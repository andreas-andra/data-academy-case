# data-academy-case

Case work for Solita 2026 Spring Data Academy.

## Project Overview

This project builds an analytics warehouse on top of Finnish public statistical data and turns it into business-ready gold models for dashboarding and AI-assisted analysis.

The implementation follows a medallion-style structure:

- `data/raw/`: source CSV extracts
- `dbt/models/silver/`: cleaned and standardized source-level models
- `dbt/models/gold/`: dimensional models and business-facing fact tables
- `docs/`: architecture diagrams, use-case documentation, and presentation support materials

The current focus is municipality-level economic analysis in Finland, especially around:

- bankruptcy pressure
- business resilience
- national economic health
- municipality-level demographic and business change

## Data Flow

The warehouse design follows a simple progression from raw data to business-facing models:

1. Raw Statistics Finland extracts are stored in `data/raw/`
2. Silver models standardize names, types, and missing-value handling
3. Gold models apply dimensional modeling and business logic
4. Databricks Genie dashboards query the gold layer

## Dimensional Modeling Approach

The gold layer follows star-schema principles where practical:

- shared dimensions:
	- `dim_year`
	- `dim_municipality`
	- `dim_industry`
- fact tables expose explicit foreign keys such as `year_id`, `municipality_id`, and `industry_id`
- year uses a stable natural key (`year_id = year`)
- municipality and industry use stable deterministic hash-based keys instead of `row_number()`

This avoids unstable surrogate keys during rebuilds and makes the data model easier to explain in documentation and presentations.

## Current Gold Models

- `fact_finland_economic_health`: national yearly economic health metrics
- `fact_bankruptcies`: municipality- and industry-level bankruptcy fact
- `fact_population`: municipality-level population and establishment fact
- `fact_municipality_overview`: municipality-level combined overview fact
- `fact_regional_mortality`: municipality-level mortality trend fact
- `fact_municipality_resilience`: municipality-level resilience scoring fact
- `fact_bankruptcy_risk_hotspots`: municipality-level bankruptcy hotspot fact
- `fact_bankruptcies_by_industry`: national yearly bankruptcy breakdown by industry

## Documentation

Additional documentation is organized under `docs/`:

- `docs/use-cases/`: business use-case documentation
- `docs/architecture/`: warehouse and modeling documentation
- `docs/diagrams/`: visual diagrams used in presentations
- `docs/presentation-outline.md`: suggested slide flow for presenting the case

Start here for the current featured use case:

- `docs/use-cases/bankruptcy-risk-hotspots.md`

## Running dbt

From the `dbt/` directory:

```bash
../dbt-venv/bin/dbt run --select models/gold/
```

To build only one model:

```bash
../dbt-venv/bin/dbt run --select fact_bankruptcy_risk_hotspots
```

To generate dbt docs:

```bash
../dbt-venv/bin/dbt docs generate
../dbt-venv/bin/dbt docs serve
```

## Use Cases Roadmap

This branch is being used to document multiple small business-facing use cases. A practical target structure is:

1. Bankruptcy Risk Hotspots
2. Municipality Business Resilience
3. Finland Economic Health
4. Bankruptcy Trends by Industry
5. Municipality Overview
6. Regional Mortality and Population Change

## Key Modeling Lessons

Some of the most important modeling corrections made during this work:

- avoided fan-out joins between fact tables of different grain
- removed double-counting caused by `industry = 'Total'` rows
- replaced unstable `row_number()` surrogate keys with stable key strategies
- removed misleading period labels that did not fit Finnish economic context
- documented the difference between relative and absolute hotspot classification
