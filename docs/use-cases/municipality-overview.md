# Municipality Overview

## Business Question

How does each municipality look at a high level when population, deaths, business base, and bankruptcy totals are viewed together?

## Business Value

This use case provides an easy municipality monitoring layer for:

- quick profiling of municipalities
- dashboard filtering and drilldown entry points
- combining demographic and business context in one place
- presentation-friendly high-level comparisons

## Gold Model

- Model: `fact_municipality_overview`
- Grain: one row per `year x municipality`
- Model style: wide municipality monitoring fact with shared dimensions

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`

## Core Metrics

- `population`
  Municipality population.

- `deaths`
  Municipality deaths.

- `death_rate_per_1000`
  Deaths normalized by population.

- `establishments_count`
  Number of establishments in the municipality.

- `personnel_staff_years`
  Municipality personnel volume.

- `total_bankruptcies_enterprises`
  Total bankruptcies in the municipality-year.

- `total_bankruptcies_employees`
  Employees affected by bankruptcies in the municipality-year.

- `bankruptcies_per_1000_establishments`
  Bankruptcy pressure relative to the local business base.

- `bankruptcies_per_100k_population`
  Bankruptcy pressure relative to municipality population.

## Key Modeling Decisions

### Wide summary fact

This fact intentionally centralizes the most commonly paired municipality metrics in one place.

### Authoritative municipality bankruptcy totals

Bankruptcy totals are sourced from the municipality `industry = 'Total'` rows rather than by summing detailed industry rows.

## Known Caveats

- this fact is convenient for overview dashboards but not a substitute for lower-grain bankruptcy or industry facts
- users should avoid joining it directly to municipality-industry facts without aggregating to a common grain first

## Recommended Dashboard Views

1. Municipality profile table for the latest year
2. Scatter plot of population vs bankruptcy pressure
3. Ranked municipality table by `bankruptcies_per_1000_establishments`
4. Small-multiple trend lines for selected municipalities

## Example Genie Questions

- Which municipalities had the highest bankruptcy pressure in the latest year?
- Which municipalities combine low population with high bankruptcy rates?
- How do deaths and bankruptcy pressure compare for a selected municipality over time?