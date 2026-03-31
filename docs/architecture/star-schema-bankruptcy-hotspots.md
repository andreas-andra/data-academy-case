# Star Schema: Bankruptcy Risk Hotspots

## Fact Table

- `fact_bankruptcy_risk_hotspots`
- Grain: one row per `year x municipality`

## Dimensions

- `dim_year`
  - joined by `year_id`
- `dim_municipality`
  - joined by `municipality_id`

## Why This Is A Star Schema

The model is intentionally organized so that descriptive context sits in dimensions and analytical measures sit in the fact.

Dimension keys in the fact:

- `year_id`
- `municipality_id`

Measures in the fact include:

- bankruptcy counts
- bankruptcy pressure rates
- year-over-year change metrics
- rolling averages
- hotspot classifications

## Diagram

See:

- `docs/diagrams/bankruptcy_risk_hotspots.png`

## Notes

- `year` and `municipality` may still appear in the fact table as analyst-friendly descriptive columns
- the star-schema diagram focuses on the dimensional relationships, not every physical column