-- Finland Economic Health: bankruptcies vs enterprise growth per year
-- Designed for the "Finland Economic Health" Genie dashboard

with national as (
    select * from {{ ref('silver_statfin_national') }}
),

-- Total bankruptcies per year (all industries combined)
yearly_totals as (
    select
        year,
        sum(case when industry = 'Total' then bankruptcies_enterprises else 0 end)  as total_bankruptcies_enterprises,
        sum(case when industry = 'Total' then bankruptcies_employees else 0 end)    as total_bankruptcies_employees,
        max(total_establishments)                                                    as total_establishments,
        max(total_personnel_staff_years)                                             as total_personnel_staff_years
    from national
    group by year
),

-- Year-over-year changes
with_growth as (
    select
        year,
        total_bankruptcies_enterprises,
        total_bankruptcies_employees,
        total_establishments,
        total_personnel_staff_years,
        total_establishments - lag(total_establishments) over (order by year)           as new_establishments_yoy,
        round(
            (total_establishments - lag(total_establishments) over (order by year))
            / nullif(lag(total_establishments) over (order by year), 0) * 100, 2
        )                                                                               as establishment_growth_pct,
        round(
            (total_bankruptcies_enterprises - lag(total_bankruptcies_enterprises) over (order by year))
            / nullif(lag(total_bankruptcies_enterprises) over (order by year), 0) * 100, 2
        )                                                                               as bankruptcy_growth_pct
    from yearly_totals
)

select * from with_growth
order by year
