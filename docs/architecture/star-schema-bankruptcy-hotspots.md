# Star Schema: Bankruptcy Risk Hotspots

## Fact Table

- `fact_bankruptcy_risk_hotspots`
- Grain: one row per `year x municipality`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_municipality`
  - joined by `municipality_id`
- `dim_industry`
  - joined by `hotspot_industry_id`

## Why This Is A Star Schema

The model is intentionally organized so that descriptive context sits in dimensions and analytical measures sit in the fact.

Dimension keys in the fact:

- `year_id`
- `municipality_id`
- `hotspot_industry_id`

Measures in the fact include:

- bankruptcy counts
- bankruptcy pressure rates
- year-over-year change metrics
- rolling averages
- hotspot classifications

## Diagram

See:

- `docs/diagrams/bankruptcy_risk_hotspots.dbml`
- `docs/diagrams/bankruptcy_risk_hotspots.png`

## Notes

- the fact table exposes only keys and measures in the implemented model
- descriptive names such as municipality and industry labels live in the dimensions