# Finland Economic Health

## Business Question

How are Finland's overall bankruptcies, business base, workforce, population, and deaths moving year over year?

## Business Value

This use case provides a compact national monitoring view for:

- macroeconomic stress tracking
- business climate monitoring
- comparing bankruptcy trends with enterprise growth
- contextualizing regional and industry-level findings

## Gold Model

- Model: `fact_finland_economic_health`
- Grain: one row per `year`
- Star-schema style: year dimension plus national annual totals and growth metrics

## Dimensions

- `dim_year`
  - `year_id`

## Core Metrics

- `total_bankruptcies_enterprises`
  Total annual bankruptcies nationally.

- `total_bankruptcies_employees`
  Annual employee exposure to bankruptcies nationally.

- `total_establishments`
  Total number of establishments in Finland.

- `total_personnel_staff_years`
  Annual personnel volume.

- `total_population`
  Finland's total population.

- `total_deaths`
  Finland's total deaths.

- `death_rate_per_1000`
  Deaths normalized by population.

- `new_establishments_yoy`
  Absolute year-over-year change in establishments.

- `establishment_growth_pct`
  Percentage year-over-year establishment growth.

- `bankruptcy_growth_pct`
  Percentage year-over-year bankruptcy growth.

## Key Modeling Decisions

### National totals only

The model intentionally collapses to year grain so it can be used as a national context layer.

### Authoritative bankruptcy totals

Bankruptcy totals are sourced from the national `industry = 'Total'` rows rather than by summing detailed industry rows.

## Known Caveats

- first-year growth fields are `NULL` because there is no prior year in the dataset
- this fact is best used for national context, not local diagnosis

## Recommended Dashboard Views

1. National bankruptcies and establishments by year
2. Bankruptcy growth vs establishment growth comparison
3. Population, deaths, and death rate trend lines
4. KPI cards for latest-year national totals

## Example Genie Questions

- Did bankruptcies grow faster than establishments in the latest year?
- How has Finland's death rate changed over time?
- Which year had the highest total bankruptcies nationally?