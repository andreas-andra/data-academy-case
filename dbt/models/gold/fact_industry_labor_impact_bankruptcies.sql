-- Industry Labor Impact of Bankruptcies
-- Grain: year × municipality × industry
-- Purpose: identify where bankruptcies affect the largest number of employees

with b as (

    select *
    from {{ ref('silver_statfin_bankruptcies') }}
    where industry != 'Total'
      and industry != 'Industry unknown'

),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_i as (select * from {{ ref('dim_industry') }}),
dim_y as (select * from {{ ref('dim_year') }}),

base as (

    select
        b.year,
        b.municipality,
        b.industry,
        b.bankruptcies_enterprises,
        b.bankruptcies_employees,

        round(
            b.bankruptcies_employees * 1.0 / nullif(b.bankruptcies_enterprises, 0),
            2
        ) as employees_affected_per_bankruptcy,

        round(
            b.bankruptcies_employees * 100.0
            / nullif(sum(b.bankruptcies_employees) over (partition by b.year, b.municipality), 0),
            2
        ) as share_of_municipality_bankrupt_employees_pct,

        round(
            b.bankruptcies_employees * 100.0
            / nullif(sum(b.bankruptcies_employees) over (partition by b.year, b.industry), 0),
            2
        ) as share_of_national_industry_bankrupt_employees_pct

    from b

),

with_trends as (

    select
        *,

        lag(year) over (
            partition by municipality, industry
            order by year
        ) as prev_year,

        lag(bankruptcies_employees) over (
            partition by municipality, industry
            order by year
        ) as prev_bankruptcies_employees,

        lag(bankruptcies_enterprises) over (
            partition by municipality, industry
            order by year
        ) as prev_bankruptcies_enterprises,

        avg(bankruptcies_employees) over (
            partition by municipality, industry
            order by year
            rows between 2 preceding and current row
        ) as rolling_3y_avg_bankruptcies_employees,

        -- ratio-of-sums, not average-of-ratios, to avoid weighting bias from small-volume years
        sum(bankruptcies_employees) over (
            partition by municipality, industry
            order by year
            rows between 2 preceding and current row
        ) * 1.0 / nullif(sum(bankruptcies_enterprises) over (
            partition by municipality, industry
            order by year
            rows between 2 preceding and current row
        ), 0) as rolling_3y_avg_employees_per_bankruptcy

    from base

),

-- Fixed global ranking bands derived from all positive-impact rows across all years.
-- Zero-impact rows are split into their own class. Positive rows are then assigned
-- to dataset-wide quartile bands using percent_rank so the classification stays
-- trend-safe across years without collapsing from discrete percentile thresholds.
positive_ranked as (

    select
        year,
        municipality,
        industry,
        percent_rank() over (order by bankruptcies_employees) as global_positive_pr
    from base
    where bankruptcies_employees > 0

),

final as (

    select
        dy.year_id,
        dm.municipality_id,
        di.industry_id,

        wt.bankruptcies_enterprises,
        wt.bankruptcies_employees,
        wt.employees_affected_per_bankruptcy,
        wt.share_of_municipality_bankrupt_employees_pct,
        wt.share_of_national_industry_bankrupt_employees_pct,

        -- NULL when the prior row is not exactly year-1 (sparse municipality-industry series).
        case when wt.prev_year = wt.year - 1 then
            round(
                (wt.bankruptcies_employees - wt.prev_bankruptcies_employees) * 100.0
                / nullif(wt.prev_bankruptcies_employees, 0),
                2
            )
        end as yoy_bankruptcies_employees_pct,

        case when wt.prev_year = wt.year - 1 then
            round(
                (wt.bankruptcies_enterprises - wt.prev_bankruptcies_enterprises) * 100.0
                / nullif(wt.prev_bankruptcies_enterprises, 0),
                2
            )
        end as yoy_bankruptcies_enterprises_pct,

        round(wt.rolling_3y_avg_bankruptcies_employees, 2) as rolling_3y_avg_bankruptcies_employees,
        round(wt.rolling_3y_avg_employees_per_bankruptcy, 2) as rolling_3y_avg_employees_per_bankruptcy,

        ntile(4) over (
            partition by wt.year
            order by wt.bankruptcies_employees desc
        ) as labor_impact_ntile,

        -- Fixed global ranking classification using all positive-impact rows.
        -- Use labor_impact_absolute_class for cross-year trend analysis.
        case
            when wt.bankruptcies_employees = 0 then 'No labor impact'
            when pr.global_positive_pr <= 0.25 then 'Low labor impact'
            when pr.global_positive_pr <= 0.50 then 'Moderate labor impact'
            when pr.global_positive_pr <= 0.75 then 'High labor impact'
            else 'Severe labor impact'
        end as labor_impact_absolute_class

    from with_trends wt
    left join positive_ranked pr
        on wt.year = pr.year
       and wt.municipality = pr.municipality
       and wt.industry = pr.industry
    left join dim_m dm on wt.municipality = dm.municipality_name
    left join dim_i di on wt.industry     = di.industry_name
    left join dim_y dy on wt.year         = dy.year

)

select
    year_id,
    municipality_id,
    industry_id,
    bankruptcies_enterprises,
    bankruptcies_employees,
    employees_affected_per_bankruptcy,
    share_of_municipality_bankrupt_employees_pct,
    share_of_national_industry_bankrupt_employees_pct,
    yoy_bankruptcies_employees_pct,
    yoy_bankruptcies_enterprises_pct,
    rolling_3y_avg_bankruptcies_employees,
    rolling_3y_avg_employees_per_bankruptcy,
    labor_impact_ntile,

    case labor_impact_ntile
        when 1 then 'Severe labor impact'
        when 2 then 'High labor impact'
        when 3 then 'Moderate labor impact'
        when 4 then 'Low labor impact'
    end as labor_impact_class,

    -- Cross-year absolute classification — use this for trend analysis of class distribution
    labor_impact_absolute_class

from final