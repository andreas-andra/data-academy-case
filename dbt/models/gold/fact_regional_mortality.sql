-- Regional Mortality Tracker: deaths and population change per municipality per year

with pop as (
    select * from {{ ref('silver_statfin_population') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_y as (select * from {{ ref('dim_year') }}),

with_change as (
    select
        year,
        municipality,
        population,
        deaths,
        lag(year) over (partition by municipality order by year)                        as prev_year,
        lag(population) over (partition by municipality order by year)                  as prev_population,
        round(deaths / nullif(population, 0) * 1000, 2)                                as death_rate_per_1000
    from pop
)

select
    dy.year_id,
    dm.municipality_id,
    wc.population,
    wc.deaths,
    case when wc.prev_year = wc.year - 1 then
        wc.population - wc.prev_population
    end as population_change_yoy,
    case when wc.prev_year = wc.year - 1 then
        round(
            (wc.population - wc.prev_population)
            / nullif(wc.prev_population, 0) * 100, 2
        )
    end as population_change_pct,
    wc.death_rate_per_1000
from with_change wc
left join dim_m dm on wc.municipality = dm.municipality_name
left join dim_y dy on wc.year = dy.year
