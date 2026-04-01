# Star Schema: Population

## Fact Table

- `fact_population`
- Grain: one row per `year x municipality`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_municipality`
  - joined by `municipality_id`

## Model Shape

This fact provides the reusable municipality denominator layer for population, establishments, and personnel.

Dimension keys in the fact:

- `year_id`
- `municipality_id`

Measures in the fact include:

- population
- establishments count
- personnel staff years

## Modeling Note

The implemented fact keeps the natural `year` value as a helper column alongside `year_id`.

## Diagram

See:

- `docs/diagrams/population.dbml`

## Notes

- this fact does not include deaths or bankruptcies; those are layered in downstream facts
- it is primarily a reusable supporting fact rather than a standalone dashboard model