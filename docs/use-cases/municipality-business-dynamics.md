# Municipality Business Dynamics

## Business Question

Which municipalities are growing or shrinking their business base, and how do establishment density, personnel trends, and population changes interact at the local level?

## Business Value

- **Municipal planners** can identify municipalities with declining business bases and target economic development interventions
- **Regional analysts** can compare business density and growth trajectories across municipalities
- **Policy makers** can spot municipalities where population is shrinking but business activity is growing (or vice versa)
- **Business strategists** can evaluate local market saturation using establishment density per capita
- **Workforce planners** can track personnel trends relative to population changes

## Gold Model

- Model: `fact_municipality_business_dynamics`
- Grain: one row per `year × municipality`
- Star-schema style: foreign keys and measures only

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`

## Core Metrics

- `establishments_count`
  Total number of business establishments in the municipality.

- `personnel_staff_years`
  Total personnel volume measured in staff-years.

- `population`
  Municipality population count.

- `establishments_per_1000_population`
  Business establishment density — establishments normalized per 1,000 residents.

- `personnel_per_1000_population`
  Personnel density — staff-years normalized per 1,000 residents.

- `avg_personnel_per_establishment`
  Average establishment size measured in personnel staff-years.

- `establishments_yoy_change`
  Year-over-year absolute change in establishment count.

- `establishments_yoy_pct`
  Year-over-year percentage change in establishment count.

- `personnel_yoy_change`
  Year-over-year absolute change in personnel staff-years.

- `personnel_yoy_pct`
  Year-over-year percentage change in personnel staff-years.

- `population_yoy_change`
  Year-over-year absolute change in population.

- `population_yoy_pct`
  Year-over-year percentage change in population.

- `rolling_3y_avg_establishments_growth_pct`
  3-year rolling average of establishment growth percentage, smoothing annual volatility.

- `business_density_class`
  Quartile classification of municipalities by establishment density: High density, Above average density, Below average density, Low density.

- `growth_class`
  Quartile classification of municipalities by establishment growth rate: Strong growth, Moderate growth, Moderate decline, Strong decline.

## Example Genie Questions

- Which municipalities had the strongest business growth last year?
- Show me municipalities classified as "Strong decline" in 2023
- What is the establishment density per 1,000 residents for Helsinki over the past 5 years?
- Which municipalities have growing businesses but shrinking populations?
- What is the 3-year rolling average establishment growth for Tampere?
- List the top 10 municipalities by personnel per 1,000 population in the latest year
- How does the average establishment size compare across high-density vs low-density municipalities?
- Which municipalities moved from "Moderate decline" to "Strong growth" between 2020 and 2023?
