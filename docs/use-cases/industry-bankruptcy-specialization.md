# Industry Bankruptcy Specialization

## Business Question

Which industries are disproportionately overrepresented in bankruptcies within each municipality compared with the national industry bankruptcy structure in the same year?

## Business Value

This use case helps identify concentrated local bankruptcy patterns for:

- municipal economic monitoring
- regional industry stress analysis
- public-sector support targeting
- lender and insurer portfolio review
- comparing local bankruptcy structure against national norms

## Gold Model

- Model: `fact_industry_bankruptcy_specialization`
- Grain: one row per `year x municipality x industry`
- Star-schema style: foreign keys and measures only; descriptive names come from dimensions

## Dimensions

- `dim_year`
  - `year_id`
- `dim_municipality`
  - `municipality_id`
- `dim_industry`
  - `industry_id`

## Core Metrics

- `bankruptcy_specialization_lq`
  Primary specialization metric. Values above 1 mean the industry is overrepresented in a municipality's bankruptcy mix relative to the national bankruptcy mix in the same year.

- `bankruptcy_employee_specialization_lq`
  Companion specialization metric based on affected employees rather than bankrupt enterprise counts.

- `specialization_gap_pct_points`
  Percentage-point gap between the municipality industry bankruptcy share and the national industry bankruptcy share.

- `municipality_total_bankruptcies_enterprises`
  Municipality-wide bankrupt enterprise total across all industries.

- `national_industry_bankruptcies_enterprises`
  National bankrupt enterprise total for the same industry and year.

- `national_total_bankruptcies_enterprises`
  National bankrupt enterprise total across all industries in the same year.

- `yoy_bankruptcy_specialization_lq_pct`
  Year-over-year change in enterprise-based specialization when the prior row is exactly the previous year.

- `rolling_3y_avg_specialization_lq`
  Three-year rolling view of enterprise-based specialization for the municipality-industry series.

## Classification Design

### `specialization_support_class`

This is the support-quality filter.

- `No bankruptcies`
- `Single bankruptcy signal`
- `Thin municipality bankruptcy base`
- `Supported signal`

Use it for:

- filtering dashboards to statistically stronger signals
- separating extreme but low-volume local ratios from more reliable cases

Important limitation:

- high specialization can appear in rows with only one bankruptcy or very small municipality totals
- dashboards should not treat all `bankruptcy_specialization_lq > 1` rows as equally reliable without checking support quality

### `specialization_absolute_class`

This is the trend-safe specialization severity classification.

- `No bankruptcies` when `bankruptcies_enterprises = 0`
- positive rows are assigned to fixed dataset-wide global quartile bands across all years combined

Use it for:

- distribution-over-time charts
- cross-year trend interpretation of specialization severity

Do not use it for:

- support-quality filtering

## Key Modeling Decisions

### Textbook star schema

The implemented model is intentionally stricter dimensional modeling:

- the fact table stores only foreign keys and measures
- municipality, industry, and year labels are retrieved from shared dimensions

### Enterprise-based primary metric

The primary specialization metric uses bankrupt enterprise counts because the business question is about overrepresentation in bankruptcy incidence.

### Employee-based companion metric

The employee-based specialization LQ is included to test whether concentration in bankrupt enterprises is also visible in workforce exposure.

### Support guardrail for extreme ratios

Very high LQ values can occur in low-volume municipalities.

The support class is included to prevent dashboards from overinterpreting mathematically extreme but operationally thin signals.

### Gap-aware YoY logic

`yoy_bankruptcy_specialization_lq_pct` is only populated when the previous row is exactly the prior calendar year.

This avoids comparing non-consecutive years and still calling the result year-over-year.

## Known Caveats

- `bankruptcy_specialization_lq > 1` indicates overrepresentation, not causality
- the most extreme overall LQ rows may be excluded from supported-only views because of low support quality
- `specialization_absolute_class` is the correct class field for trend analysis
- dashboards that show municipality or industry names must join through dimensions
- this fact should not be joined directly to municipality-level facts without first aggregating to a common grain

## Recommended Dashboard Views

1. Latest-year supported overrepresented municipality-industry combinations by `bankruptcy_specialization_lq`
2. Distribution of `specialization_absolute_class` by year
3. Heatmap of supported `bankruptcy_specialization_lq > 1` rows by municipality and industry
4. Industries most often overrepresented across all years under the supported filter
5. Scatter plot of enterprise specialization vs employee specialization for 2024
6. Support-quality breakdown across all rows

## Example Genie Questions

- Which municipality-industry combinations are most overrepresented in bankruptcies in the latest year under the supported filter?
- Which industries are most often overrepresented across Finland when only supported signals are counted?
- How has the count of very high `specialization_absolute_class` rows changed over time?
- Which 2024 rows have high enterprise specialization but much lower employee specialization?
- For a given municipality, which industries are most overrepresented relative to the national bankruptcy pattern?