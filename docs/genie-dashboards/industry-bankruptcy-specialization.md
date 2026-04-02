# Genie Dashboard: Industry Bankruptcy Specialization

## Business Question
Identify which industries are disproportionately overrepresented in municipal bankruptcies relative to the national industry bankruptcy structure in the same year.

## Base Table
`fact_industry_bankruptcy_specialization`

## Required Joins
- `dim_year` on `fact_industry_bankruptcy_specialization.year_id = dim_year.year_id`
- `dim_municipality` on `fact_industry_bankruptcy_specialization.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact_industry_bankruptcy_specialization.industry_id = dim_industry.industry_id`

Use labels from dimensions only:
- `dim_year.year`
- `dim_municipality.municipality_name`
- `dim_industry.industry_name`

---

## Metric Rules
- **Primary metric**: `bankruptcy_specialization_lq` — use for all rankings, KPIs, top-N charts, heatmap, and validation tables
- **Supporting metric**: `bankruptcy_employee_specialization_lq` — use only for the enterprise-vs-employee scatter plot (Chart 5)
- **Overrepresentation rule**: `bankruptcy_specialization_lq > 1`
- **Cross-year trend classification**: `specialization_absolute_class` — do not use `specialization_class` for trend analysis

## Default Dashboard Filter
Apply `specialization_support_class = 'Supported signal'` to all KPI text and all charts unless a chart is explicitly defined as an exception.

### Explicit Exceptions
- **Chart 5**: may include `specialization_support_class in ('Supported signal', 'Thin municipality bankruptcy base')`
- **Chart 6**: must include all support classes
- **Validation table** (last page): may include all support classes, but narrative must explicitly distinguish all-row rankings from the default supported-only dashboard view

---

## Critical Consistency Rules
- Do not mix supported-only metrics with all-support-class metrics in the same sentence
- If you mention the highest overall 2024 specialization regardless of support class, label it explicitly as outside the default filter
- If you mention the highest specialization under the default filter, use only `specialization_support_class = 'Supported signal'` and `bankruptcy_specialization_lq > 1`
- When describing Chart 1, only mention rows that satisfy the default filter
- When describing the validation table, do not claim that only Nykarleby is Supported signal if other top rows are also Supported signal

---

## Executive Summary (2024, Default Filter)

Report using `year = 2024`, `specialization_support_class = 'Supported signal'`, `bankruptcy_specialization_lq > 1`:

- **Supported overrepresented combinations in 2024**: 288
- **Average bankruptcy_specialization_lq for that set**: 2.46
- **Highest specialization under default filter**: Nykarleby, Agriculture, forestry and fishing, 22.181
- **Most frequently overrepresented industry in 2024**: Construction, 61 cases

Do not use 1.95 in the executive summary if the sentence refers to the 288 overrepresented supported rows.
Do not use Kaustinen 36.97 as the highest specialization unless explicitly labeled as outside the default support filter.

---

## Headline KPIs (2024)

All KPIs use the same scope: `year = 2024`, `specialization_support_class = 'Supported signal'`, `bankruptcy_specialization_lq > 1`.

| KPI | Value |
|-----|-------|
| Total Overrepresented Combinations | 288 |
| Average Specialization LQ | 2.46 |
| Highest Specialization (Default Filter) | Nykarleby, Agriculture, forestry and fishing — 22.181 |
| Most Overrepresented Industry | Construction — 61 cases |

If mentioning the absolute highest overall 2024 specialization outside the default filter, present it separately as an additional note, not as the default-filter KPI.

---

## Charts

### Chart 1 — Bar Chart: Top 20 Municipality-Industry Specialization Combinations (2024)
- Filter: `year = 2024`, `specialization_support_class = 'Supported signal'`, `bankruptcy_specialization_lq > 1`
- Sort descending by `bankruptcy_specialization_lq`
- Narrative must mention only supported rows
- Leading rows:
  1. Nykarleby, Agriculture, forestry and fishing — 22.181
  2. Lappajärvi, Agriculture, forestry and fishing — 18.484
  3. Kiuruvesi, Agriculture, forestry and fishing — 15.843
  4. Ylitornio, Transport and storage — 14.850

### Chart 2 — Stacked Bar Chart: Specialization Distribution Over Time (2020–2024)
- Filter: `specialization_support_class = 'Supported signal'`
- Classification: `specialization_absolute_class`
- Categories: Low specialization, Moderate specialization, High specialization, Very high specialization
- Narrative: Very high specialization cases rise from 29 in 2020 to 53 in 2024
- **Do not use** `specialization_class` for this trend chart

### Chart 3 — Heatmap: Municipality by Industry Specialization Matrix (2024)
- Filter: `year = 2024`, `specialization_support_class = 'Supported signal'`, `bankruptcy_specialization_lq > 1`
- Color by: `bankruptcy_specialization_lq`
- Supporting facts:
  - Total displayed cells: 288
  - Min displayed LQ: 1.01
  - Max displayed LQ: 22.181

### Chart 4 — Bar Chart: Industries Most Often Overrepresented (All Years)
- Filter: `specialization_support_class = 'Supported signal'`, `bankruptcy_specialization_lq > 1`
- Group by: `industry_name`, count rows
- Values:
  - Construction: 279
  - Trade: 218
  - Other service activities: 217
  - Manufacturing, mining and quarrying: 170
  - Hotels and restaurants: 156
  - Agriculture, forestry and fishing: 57
- Narrative: Agriculture, forestry and fishing has the most extreme individual LQ scores but only 57 supported overrepresentation cases across all years

### Chart 5 — Scatter Plot: Enterprise vs Employee Specialization (2024)
- **Exception to default filter**: `specialization_support_class in ('Supported signal', 'Thin municipality bankruptcy base')`
- Filter: `year = 2024`, `bankruptcy_specialization_lq > 1`
- X-axis: `bankruptcy_specialization_lq`
- Y-axis: `bankruptcy_employee_specialization_lq`
- Supporting facts:
  - Point count: 307
  - Correlation: ~0.919 (strongly positive)
  - Max enterprise LQ: 36.968
  - Max employee LQ: 46.5

### Chart 6 — Bar Chart: Support Quality Breakdown (All Rows)
- **Exception to default filter**: includes all support classes
- Group by: `specialization_support_class`
- Values:
  - Supported signal: 1,709
  - Thin municipality bankruptcy base: 105
  - Single bankruptcy signal: 1,984
  - No bankruptcies: 6,982

---

## Validation Table: Top 10 Municipality-Industry Combinations (2024)

All support classes included. Sort by `bankruptcy_specialization_lq` descending.

Columns: municipality_name, industry_name, bankruptcies_enterprises, bankruptcy_specialization_lq, bankruptcy_employee_specialization_lq, specialization_support_class

Interpretation:
- Several Agriculture, forestry and fishing rows have the highest overall 2024 LQ of 36.97
- Those rows are not in the default supported-only dashboard view (Single bankruptcy signal or Thin municipality bankruptcy base)
- Within the default supported-only view, Nykarleby at 22.181 is the top case
- Lappajärvi at 18.484 and Kiuruvesi at 15.843 are also Supported signal rows and appear in Chart 1
- Do not say only Nykarleby qualifies as Supported signal

---

## Technical Validation

- Base table: `fact_industry_bankruptcy_specialization`
- Joins: `dim_year`, `dim_municipality`, `dim_industry`
- Display labels come from dimensions
- Default filter: `specialization_support_class = 'Supported signal'`
- Exceptions: Chart 5 and Chart 6
- Overrepresentation: `bankruptcy_specialization_lq > 1`

## Metric Usage

| Role | Column |
|------|--------|
| Primary metric | `bankruptcy_specialization_lq` |
| Supporting metric | `bankruptcy_employee_specialization_lq` |
| Cross-year trend classification | `specialization_absolute_class` |
| Overrepresentation rule | `bankruptcy_specialization_lq > 1` |

## Final Validation Requirement

Before finalizing dashboard text, verify every KPI and sentence uses the same filter as the chart or claim it describes. Prevent these mistakes:
- Do not pair 288 supported overrepresented combinations with an average of 1.95
- Do not present Kaustinen 36.97 as the highest specialization under the default supported filter
- Do not say only Nykarleby is Supported signal in the validation table narrative
