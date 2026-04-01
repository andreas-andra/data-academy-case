# Bankruptcy Trends By Industry

## Business Question

Which industries contribute most to national bankruptcies, and how does that industry mix change over time?

## Business Value

This use case helps analyze sector-level bankruptcy pressure for:

- national industry monitoring
- lender and insurer sector-risk review
- trend analysis of changing bankruptcy mix
- identifying industries that are persistently overrepresented in bankruptcies

## Gold Model

- Model: `fact_bankruptcies_by_industry`
- Grain: one row per `year x industry`
- Star-schema style: shared year and industry dimensions with annual bankruptcy measures

## Dimensions

- `dim_year`
  - `year_id`
- `dim_industry`
  - `industry_id`

## Core Metrics

- `bankruptcies_enterprises`
  National bankrupt enterprise count for the industry-year.

- `bankruptcies_employees`
  Employees affected by bankruptcies in the industry-year.

- `share_of_total_pct`
  The industry's share of all bankruptcies nationally in the same year.

## Key Modeling Decisions

### Clean industry grain

The model excludes `Total` and `Industry unknown` rows so each row represents a real industry category.

### National scope only

This is a Finland-level trend fact, not a municipality-industry fact.

## Known Caveats

- this fact is appropriate for national trend views, not local drilldowns
- users who need municipality detail should switch to `fact_bankruptcies` or the more specialized municipality-industry facts

## Recommended Dashboard Views

1. Latest-year industries by `bankruptcies_enterprises`
2. Industry share-of-total trend lines over time
3. Top industries by `bankruptcies_employees`
4. Stacked area chart of annual bankruptcy mix by industry

## Example Genie Questions

- Which industries had the most bankruptcies nationally in the latest year?
- How has construction's share of total bankruptcies changed over time?
- Which industries had the highest employee impact from bankruptcies last year?