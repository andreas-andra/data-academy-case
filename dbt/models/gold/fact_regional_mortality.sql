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
        population - lag(population) over (partition by municipality order by year)     as population_change_yoy,
        round(
            (population - lag(population) over (partition by municipality order by year))
            / nullif(lag(population) over (partition by municipality order by year), 0) * 100, 2
        )                                                                               as population_change_pct,
        round(deaths / nullif(population, 0) * 1000, 2)                                as death_rate_per_1000
    from pop
)

select
    wc.year,
    dy.year_id,
    dm.municipality_id,
    wc.population,
    wc.deaths,
    wc.population_change_yoy,
    wc.population_change_pct,
    wc.death_rate_per_1000
from with_change wc
left join dim_m dm on wc.municipality = dm.municipality_name
left join dim_y dy on wc.year = dy.year
