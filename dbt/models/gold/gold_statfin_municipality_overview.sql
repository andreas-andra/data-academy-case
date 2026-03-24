with bankruptcies as (
    select * from {{ ref('silver_statfin_bankruptcies') }}
),

enterprises as (
    select * from {{ ref('silver_statfin_enterprise_establishments') }}
),

population as (
    select * from {{ ref('silver_statfin_population') }}
),

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

select * from joined
