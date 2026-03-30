with bankruptcies as (
    select * from {{ ref('silver_statfin_bankruptcies') }}
),

enterprises as (
    select * from {{ ref('silver_statfin_enterprise_establishments') }}
),

population as (
    select * from {{ ref('silver_statfin_population') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_y as (select * from {{ ref('dim_year') }}),

-- Aggregate bankruptcies per municipality/year (sum across all industries)
bankruptcies_agg as (
    select
        year,
        municipality,
        sum(bankruptcies_enterprises)   as total_bankruptcies_enterprises,
        sum(bankruptcies_employees)     as total_bankruptcies_employees
    from bankruptcies
    where industry = 'Total'
    group by year, municipality
),

joined as (
    select
        p.year,
        p.municipality,
        p.population,
        p.deaths,
        round(p.deaths / nullif(p.population, 0) * 1000, 2)                              as death_rate_per_1000,
        e.establishments_count,
        e.personnel_staff_years,
        b.total_bankruptcies_enterprises,
        b.total_bankruptcies_employees,
        -- Derived metrics
        round(b.total_bankruptcies_enterprises / nullif(e.establishments_count, 0) * 1000, 2)
            as bankruptcies_per_1000_establishments,
        round(b.total_bankruptcies_enterprises / nullif(p.population, 0) * 100000, 2)
            as bankruptcies_per_100k_population
    from population p
    left join enterprises e
        on p.year = e.year and p.municipality = e.municipality
    left join bankruptcies_agg b
        on p.year = b.year and p.municipality = b.municipality
)

select
    j.year,
    dm.municipality_id,
    j.population,
    j.deaths,
    j.death_rate_per_1000,
    j.establishments_count,
    j.personnel_staff_years,
    j.total_bankruptcies_enterprises,
    j.total_bankruptcies_employees,
    j.bankruptcies_per_1000_establishments,
    j.bankruptcies_per_100k_population
from joined j
left join dim_m dm on j.municipality = dm.municipality_name
left join dim_y dy on j.year         = dy.year
