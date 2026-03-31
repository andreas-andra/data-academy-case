-- Finland Economic Health: bankruptcies vs enterprise growth per year
-- Designed for the "Finland Economic Health" Genie dashboard

with national as (
    select * from {{ ref('silver_statfin_national') }}
),

dim_y as (select * from {{ ref('dim_year') }}),

-- Total bankruptcies per year (all industries combined)
yearly_totals as (
    select
        year,
        sum(case when industry = 'Total' then bankruptcies_enterprises else 0 end)  as total_bankruptcies_enterprises,
        sum(case when industry = 'Total' then bankruptcies_employees else 0 end)    as total_bankruptcies_employees,
        max(total_establishments)                                                    as total_establishments,
        max(total_personnel_staff_years)                                             as total_personnel_staff_years,
        max(total_population)                                                        as total_population,
        max(total_deaths)                                                            as total_deaths
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
        total_population,
        total_deaths,
        round(total_deaths / nullif(total_population, 0) * 1000, 2)                     as death_rate_per_1000,
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

select
    wg.year,
    dy.year_id,
    wg.total_bankruptcies_enterprises,
    wg.total_bankruptcies_employees,
    wg.total_establishments,
    wg.total_personnel_staff_years,
    wg.total_population,
    wg.total_deaths,
    wg.death_rate_per_1000,
    wg.new_establishments_yoy,
    wg.establishment_growth_pct,
    wg.bankruptcy_growth_pct
from with_growth wg
left join dim_y dy on wg.year = dy.year
order by wg.year
