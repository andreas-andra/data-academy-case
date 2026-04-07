{{ config(materialized='table') }}

-- Economic Shock Exposure Index: rolling 3-year coefficient of variation (CV)
-- across bankruptcy, business, and demographic volatility dimensions.
-- Grain: year × municipality
-- CV measures are NULL when fewer than 3 consecutive years of data exist for a municipality.
-- shock_resilience_ntile uses ntile(4) partitioned by year on shock_exposure_composite ASC:
--   1 = most resilient, 4 = most fragile (Crisis-prone).

with bk as (

    -- Use the authoritative industry='Total' row to get municipality-level bankruptcy totals.
    -- Avoids double-counting individual industry rows.
    select
        year,
        municipality,
        bankruptcies_enterprises,
        bankruptcies_employees
    from {{ ref('silver_statfin_bankruptcies') }}
    where industry = 'Total'

),

est as (
    select * from {{ ref('silver_statfin_enterprise_establishments') }}
),

pop as (
    select * from {{ ref('silver_statfin_population') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_y as (select * from {{ ref('dim_year') }}),

base as (

    select
        p.year,
        p.municipality,
        p.population,
        p.deaths,
        e.establishments_count,
        e.personnel_staff_years,
        coalesce(b.bankruptcies_enterprises, 0)                             as bankruptcies_enterprises,
        coalesce(b.bankruptcies_employees, 0)                               as bankruptcies_employees,

        round(
            coalesce(b.bankruptcies_enterprises, 0) * 1000.0
            / nullif(e.establishments_count, 0),
            4
        )                                                                   as bankruptcy_rate_per_1000,

        round(
            coalesce(b.bankruptcies_employees, 0) * 1000.0
            / nullif(e.personnel_staff_years, 0),
            4
        )                                                                   as employee_impact_rate,

        round(
            p.deaths * 1000.0
            / nullif(p.population, 0),
            4
        )                                                                   as death_rate_per_1000

    from pop p
    left join est e
        on  p.year         = e.year
        and p.municipality = e.municipality
    left join bk b
        on  p.year         = b.year
        and p.municipality = b.municipality

),

with_lag as (

    select
        *,
        lag(year)                 over (partition by municipality order by year) as prev_year,
        lag(establishments_count) over (partition by municipality order by year) as prev_establishments_count,
        lag(population)           over (partition by municipality order by year) as prev_population
    from base

),

with_yoy as (

    select
        *,

        -- Guard: only compute YoY when the prior row is exactly year-1 (sparse series guard)
        case when prev_year = year - 1 then
            round(
                (establishments_count - prev_establishments_count) * 100.0
                / nullif(prev_establishments_count, 0),
                4
            )
        end as establishments_yoy_pct,

        case when prev_year = year - 1 then
            round(
                (population - prev_population) * 100.0
                / nullif(prev_population, 0),
                4
            )
        end as population_change_pct

    from with_lag

),

with_cv as (

    select
        *,

        -- Window row count used to gate CVs: only report when 3 full calendar years are present
        count(*) over (
            partition by municipality
            order by year
            rows between 2 preceding and current row
        ) as window_row_count,

        -- 1. Bankruptcy rate CV
        stddev(bankruptcy_rate_per_1000) over (
            partition by municipality order by year
            rows between 2 preceding and current row
        )
        / nullif(
            avg(bankruptcy_rate_per_1000) over (
                partition by municipality order by year
                rows between 2 preceding and current row
            ), 0
        )                                                                   as bankruptcy_rate_cv_3y_raw,

        -- 2. Employee impact CV (bankrupt employees per 1000 personnel)
        stddev(employee_impact_rate) over (
            partition by municipality order by year
            rows between 2 preceding and current row
        )
        / nullif(
            avg(employee_impact_rate) over (
                partition by municipality order by year
                rows between 2 preceding and current row
            ), 0
        )                                                                   as employee_impact_cv_3y_raw,

        -- 3. Business churn CV (CV of establishments YoY %)
        stddev(establishments_yoy_pct) over (
            partition by municipality order by year
            rows between 2 preceding and current row
        )
        / nullif(
            avg(establishments_yoy_pct) over (
                partition by municipality order by year
                rows between 2 preceding and current row
            ), 0
        )                                                                   as business_churn_cv_3y_raw,

        -- 4. Personnel CV (CV of raw personnel_staff_years)
        stddev(personnel_staff_years) over (
            partition by municipality order by year
            rows between 2 preceding and current row
        )
        / nullif(
            avg(personnel_staff_years) over (
                partition by municipality order by year
                rows between 2 preceding and current row
            ), 0
        )                                                                   as personnel_cv_3y_raw,

        -- 5. Demographic stability CV (CV of population YoY %)
        stddev(population_change_pct) over (
            partition by municipality order by year
            rows between 2 preceding and current row
        )
        / nullif(
            avg(population_change_pct) over (
                partition by municipality order by year
                rows between 2 preceding and current row
            ), 0
        )                                                                   as demographic_stability_cv_3y_raw

    from with_yoy

),

with_guarded_cv as (

    -- Null out all CVs when window has fewer than 3 calendar rows
    select
        *,
        case when window_row_count >= 3 then round(bankruptcy_rate_cv_3y_raw,       4) end as bankruptcy_rate_cv_3y,
        case when window_row_count >= 3 then round(employee_impact_cv_3y_raw,        4) end as employee_impact_cv_3y,
        case when window_row_count >= 3 then round(business_churn_cv_3y_raw,         4) end as business_churn_cv_3y,
        case when window_row_count >= 3 then round(personnel_cv_3y_raw,              4) end as personnel_cv_3y,
        case when window_row_count >= 3 then round(demographic_stability_cv_3y_raw,  4) end as demographic_stability_cv_3y
    from with_cv

),

with_composite as (

    select
        *,
        -- Composite is NULL for early years (window_row_count < 3).
        -- Within the window, coalesce(cv, 0) prevents an individually-null component
        -- from nulling out the whole composite.
        case when window_row_count >= 3 then
            round(
                  0.35 * coalesce(bankruptcy_rate_cv_3y, 0)
                + 0.25 * coalesce(employee_impact_cv_3y, 0)
                + 0.20 * coalesce(business_churn_cv_3y, 0)
                + 0.10 * coalesce(personnel_cv_3y, 0)
                + 0.10 * coalesce(demographic_stability_cv_3y, 0),
                4
            )
        end as shock_exposure_composite
    from with_guarded_cv

),

classified as (

    select
        *,
        case
            when shock_exposure_composite is not null
            then ntile(4) over (
                partition by year
                order by shock_exposure_composite asc
            )
        end as shock_resilience_ntile
    from with_composite

)

select
    dy.year_id,
    c.year,
    dm.municipality_id,
    dm.municipality_name,

    -- Rolling 3-year CV measures (NULL when fewer than 3 years of data exist)
    c.bankruptcy_rate_cv_3y,
    c.employee_impact_cv_3y,
    c.business_churn_cv_3y,
    c.personnel_cv_3y,
    c.demographic_stability_cv_3y,

    -- Composite shock exposure index (NULL when fewer than 3 years of data exist)
    c.shock_exposure_composite,

    -- Resilience classification (1 = most resilient, 4 = most fragile)
    c.shock_resilience_ntile,
    case c.shock_resilience_ntile
        when 1 then 'High Resilience'
        when 2 then 'Moderate Resilience'
        when 3 then 'Fragile'
        when 4 then 'Crisis-prone'
    end                                                 as shock_resilience_class,

    -- Current-year snapshot measures (for dashboard context)
    round(c.bankruptcy_rate_per_1000, 2)                as bankruptcy_rate_per_1000,
    c.establishments_count,
    c.population,
    c.deaths,
    round(c.death_rate_per_1000, 2)                     as death_rate_per_1000,

    -- YoY component measures (inputs to CV calculation; exposed for drill-down)
    c.establishments_yoy_pct,
    c.population_change_pct

from classified c
left join dim_m dm on c.municipality = dm.municipality_name
left join dim_y dy on c.year         = dy.year
