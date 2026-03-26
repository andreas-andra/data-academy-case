with p as (
    select * from {{ ref('silver_statfin_population') }}
),

e as (
    select * from {{ ref('silver_statfin_enterprise_establishments') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_y as (select * from {{ ref('dim_year') }})

select
    p.year,
    dy.period_label,
    dm.municipality_id,
    p.population,
    e.establishments_count,
    e.personnel_staff_years
from p
left join e     on p.year = e.year and p.municipality = e.municipality
left join dim_m dm on p.municipality = dm.municipality_name
left join dim_y dy on p.year         = dy.year
