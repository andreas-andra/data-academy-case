# Star Schema: Municipality Overview

## Fact Table

- `fact_municipality_overview`
- Grain: one row per `year x municipality`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_municipality`
  - joined by `municipality_id`

## Model Shape

The implemented fact combines municipality demographics, business-base metrics, and bankruptcy totals in one wide monitoring table.

Dimension keys in the fact:

- `year_id`
- `municipality_id`

Measures in the fact include:

- population and deaths
- death rate
- establishment and personnel counts
- total bankruptcies enterprises and employees
- bankruptcy rates per establishment and per population

## Modeling Note

This fact keeps the natural `year` value as a helper column alongside `year_id`.

That makes the implemented model slightly wider than a strict textbook star, but still dimension-oriented and easy to join consistently.

## Diagram

See:

- `docs/diagrams/municipality_overview.dbml`

## Notes

- municipality bankruptcy totals are sourced from the authoritative `industry = 'Total'` rows
- this is a presentation-friendly municipality summary fact rather than the most normalized analytical fact in the project