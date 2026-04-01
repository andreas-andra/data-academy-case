-- Industry Bankruptcy Specialization
-- Grain: year × municipality × industry
-- Purpose: identify industries that are disproportionately overrepresented
-- in a municipality's bankruptcy profile relative to the national structure

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

        sum(b.bankruptcies_enterprises) over (
            partition by b.year, b.municipality
        ) as municipality_total_bankruptcies_enterprises,

        sum(b.bankruptcies_enterprises) over (
            partition by b.year, b.industry
        ) as national_industry_bankruptcies_enterprises,

        sum(b.bankruptcies_enterprises) over (
            partition by b.year
        ) as national_total_bankruptcies_enterprises,

        sum(b.bankruptcies_employees) over (
            partition by b.year, b.municipality
        ) as municipality_total_bankruptcies_employees,

        sum(b.bankruptcies_employees) over (
            partition by b.year, b.industry
        ) as national_industry_bankruptcies_employees,

        sum(b.bankruptcies_employees) over (
            partition by b.year
        ) as national_total_bankruptcies_employees,

        round(
            b.bankruptcies_enterprises * 100.0
            / nullif(sum(b.bankruptcies_enterprises) over (
                partition by b.year, b.municipality
            ), 0),
            2
        ) as municipality_industry_bankruptcy_share_pct,

        round(
            sum(b.bankruptcies_enterprises) over (
                partition by b.year, b.industry
            ) * 100.0
            / nullif(sum(b.bankruptcies_enterprises) over (
                partition by b.year
            ), 0),
            2
        ) as national_industry_bankruptcy_share_pct,

        round(
            b.bankruptcies_employees * 100.0
            / nullif(sum(b.bankruptcies_employees) over (
                partition by b.year, b.municipality
            ), 0),
            2
        ) as municipality_industry_bankrupt_employees_share_pct,

        round(
            sum(b.bankruptcies_employees) over (
                partition by b.year, b.industry
            ) * 100.0
            / nullif(sum(b.bankruptcies_employees) over (
                partition by b.year
            ), 0),
            2
        ) as national_industry_bankrupt_employees_share_pct,

        round(
            (
                b.bankruptcies_enterprises * 1.0
                / nullif(sum(b.bankruptcies_enterprises) over (
                    partition by b.year, b.municipality
                ), 0)
            )
            / nullif(
                (
                    sum(b.bankruptcies_enterprises) over (
                        partition by b.year, b.industry
                    ) * 1.0
                    / nullif(sum(b.bankruptcies_enterprises) over (
                        partition by b.year
                    ), 0)
                ),
                0
            ),
            3
        ) as bankruptcy_specialization_lq,

        round(
            (
                b.bankruptcies_employees * 1.0
                / nullif(sum(b.bankruptcies_employees) over (
                    partition by b.year, b.municipality
                ), 0)
            )
            / nullif(
                (
                    sum(b.bankruptcies_employees) over (
                        partition by b.year, b.industry
                    ) * 1.0
                    / nullif(sum(b.bankruptcies_employees) over (
                        partition by b.year
                    ), 0)
                ),
                0
            ),
            3
        ) as bankruptcy_employee_specialization_lq

    from b

),

with_trends as (

    select
        *,

        round(
            municipality_industry_bankruptcy_share_pct
            - national_industry_bankruptcy_share_pct,
            2
        ) as specialization_gap_pct_points,

        lag(year) over (
            partition by municipality, industry
            order by year
        ) as prev_year,

        lag(bankruptcy_specialization_lq) over (
            partition by municipality, industry
            order by year
        ) as prev_bankruptcy_specialization_lq,

        avg(bankruptcy_specialization_lq) over (
            partition by municipality, industry
            order by year
            rows between 2 preceding and current row
        ) as rolling_3y_avg_specialization_lq

    from base

),

-- Fixed global ranking bands derived from all positive-specialization rows across all years.
-- Rows with zero bankruptcies get their own class because specialization is not meaningful there.
positive_ranked as (

    select
        year,
        municipality,
        industry,
        percent_rank() over (order by bankruptcy_specialization_lq) as global_positive_pr
    from base
    where bankruptcies_enterprises > 0

),

relative_ranked as (

    select
        year,
        municipality,
        industry,
        ntile(4) over (
            partition by year
            order by bankruptcy_specialization_lq desc
        ) as specialization_ntile
    from base
    where bankruptcies_enterprises > 0

),

final as (

    select
        dy.year_id,
        dm.municipality_id,
        di.industry_id,

        wt.bankruptcies_enterprises,
        wt.bankruptcies_employees,
        wt.municipality_total_bankruptcies_enterprises,
        wt.national_industry_bankruptcies_enterprises,
        wt.national_total_bankruptcies_enterprises,
        wt.municipality_total_bankruptcies_employees,
        wt.national_industry_bankruptcies_employees,
        wt.national_total_bankruptcies_employees,
        wt.municipality_industry_bankruptcy_share_pct,
        wt.national_industry_bankruptcy_share_pct,
        wt.municipality_industry_bankrupt_employees_share_pct,
        wt.national_industry_bankrupt_employees_share_pct,
        wt.bankruptcy_specialization_lq,
        wt.bankruptcy_employee_specialization_lq,
        wt.specialization_gap_pct_points,

        -- NULL when the prior row is not exactly year-1 (sparse municipality-industry series).
        case when wt.prev_year = wt.year - 1 then
            round(
                (wt.bankruptcy_specialization_lq - wt.prev_bankruptcy_specialization_lq) * 100.0
                / nullif(wt.prev_bankruptcy_specialization_lq, 0),
                2
            )
        end as yoy_bankruptcy_specialization_lq_pct,

        round(wt.rolling_3y_avg_specialization_lq, 3) as rolling_3y_avg_specialization_lq,
        rr.specialization_ntile,

        case
            when wt.bankruptcies_enterprises = 0 then 'No bankruptcies'
            when wt.bankruptcies_enterprises = 1 then 'Single bankruptcy signal'
            when wt.municipality_total_bankruptcies_enterprises <= 3 then 'Thin municipality bankruptcy base'
            else 'Supported signal'
        end as specialization_support_class,

        -- Fixed global ranking classification using all positive-specialization rows.
        -- Use specialization_absolute_class for cross-year trend analysis.
        case
            when wt.bankruptcies_enterprises = 0 then 'No bankruptcies'
            when pr.global_positive_pr <= 0.25 then 'Low specialization'
            when pr.global_positive_pr <= 0.50 then 'Moderate specialization'
            when pr.global_positive_pr <= 0.75 then 'High specialization'
            else 'Very high specialization'
        end as specialization_absolute_class

    from with_trends wt
    left join positive_ranked pr
        on wt.year = pr.year
       and wt.municipality = pr.municipality
       and wt.industry = pr.industry
    left join relative_ranked rr
        on wt.year = rr.year
       and wt.municipality = rr.municipality
       and wt.industry = rr.industry
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
    municipality_total_bankruptcies_enterprises,
    national_industry_bankruptcies_enterprises,
    national_total_bankruptcies_enterprises,
    municipality_total_bankruptcies_employees,
    national_industry_bankruptcies_employees,
    national_total_bankruptcies_employees,
    municipality_industry_bankruptcy_share_pct,
    national_industry_bankruptcy_share_pct,
    municipality_industry_bankrupt_employees_share_pct,
    national_industry_bankrupt_employees_share_pct,
    bankruptcy_specialization_lq,
    bankruptcy_employee_specialization_lq,
    specialization_gap_pct_points,
    yoy_bankruptcy_specialization_lq_pct,
    rolling_3y_avg_specialization_lq,
    specialization_ntile,
    specialization_support_class,

    case
        when bankruptcies_enterprises = 0 then 'No bankruptcies'
        when specialization_ntile = 1 then 'Very high specialization'
        when specialization_ntile = 2 then 'High specialization'
        when specialization_ntile = 3 then 'Moderate specialization'
        when specialization_ntile = 4 then 'Low specialization'
    end as specialization_class,

    -- Cross-year absolute classification — use this for trend analysis of class distribution
    specialization_absolute_class

from final