# Genie Dashboard: Industry Labor Impact of Bankruptcies

## Base Table
`fact_industry_labor_impact_bankruptcies`

## Required Joins
- `dim_year` on `fact.year_id = dim_year.year_id`
- `dim_municipality` on `fact.municipality_id = dim_municipality.municipality_id`
- `dim_industry` on `fact.industry_id = dim_industry.industry_id`

Use `dim_year.year` for year labels.
Use `dim_municipality.municipality_name` for municipality labels.
Use `dim_industry.industry_name` for industry labels.

---

## Genie Prompts

"Using fact_industry_labor_impact_bankruptcies, show total bankruptcies_employees by industry for year = 2023 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies, show total bankruptcies_enterprises by industry for year = 2023 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies, show yearly total bankruptcies_employees as a line chart. Group only by year."

"Using fact_industry_labor_impact_bankruptcies, show yearly total bankruptcies_enterprises as a line chart. Group only by year."

"Using fact_industry_labor_impact_bankruptcies, show bankruptcies_employees by industry and year as a heatmap. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies, show the top 5 industries by total bankruptcies_employees across all years, then plot those industries over time as a multi-line chart."

"Using fact_industry_labor_impact_bankruptcies, show average employees_affected_per_bankruptcy by industry for year = 2023 as a descending bar chart. Aggregate across municipalities."

"Using fact_industry_labor_impact_bankruptcies, show rolling_3y_avg_employees_per_bankruptcy by industry and year as a line chart for the top 5 industries by total bankruptcies_employees."

"Using fact_industry_labor_impact_bankruptcies, show labor_impact_absolute_class distribution by year as a stacked bar chart. Count rows, do not sum employees."

"Using fact_industry_labor_impact_bankruptcies, show labor_impact_class distribution by year as a stacked bar chart. Count rows, do not sum employees."

"Using fact_industry_labor_impact_bankruptcies, for municipality = Helsinki, show bankruptcies_employees by industry and year as a stacked bar chart."

"Using fact_industry_labor_impact_bankruptcies, find municipality-industry combinations in year = 2023 where labor_impact_class = 'Severe labor impact' and sort by bankruptcies_employees descending."
