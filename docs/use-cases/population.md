# Population And Business Base

## Business Question

How do population, deaths, establishments, and personnel vary across municipalities and over time?

## Business Value

This use case supports:

- demographic monitoring across municipalities
- comparing municipality scale and business base
- providing denominator context for downstream rate-based facts
- supporting national and municipality trend views for population and enterprise base

## Gold Model

- Model: `fact_population`
- Grain: one row per `year x municipality`
- Star-schema style: shared year and municipality dimensions with demographic and business-base measures

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

- `establishments_count`
  Number of establishments in the municipality.

- `personnel_staff_years`
  Municipality personnel volume in staff-years.

## Key Modeling Decisions

### Foundational denominator fact

This fact is the reusable municipality denominator layer for demographic and business-base context.

### Joined population and enterprise context

Population and deaths are combined with establishments and personnel so municipality scale and business base can be analyzed together at a common grain.

## Known Caveats

- this fact does not include bankruptcy measures or industry detail
- for municipality views that already combine these measures with bankruptcy totals, use `fact_municipality_overview`

## Recommended Dashboard Views

1. Top municipalities by population in the latest year
2. Top municipalities by establishments count in the latest year
3. National population and establishments trends over time
4. Population versus establishments scatter plot for the latest year

## Example Genie Questions

- Which municipalities have the largest populations in the latest year?
- Which municipalities have the largest business base by establishments count?
- How have national population and establishments changed over time?
