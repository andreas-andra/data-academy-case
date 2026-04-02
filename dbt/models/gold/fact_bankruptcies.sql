with b as (
    select * from {{ ref('silver_statfin_bankruptcies') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_i as (select * from {{ ref('dim_industry') }}),
dim_y as (select * from {{ ref('dim_year') }})

select
    dy.year_id,
    dm.municipality_id,
    di.industry_id,
    b.bankruptcies_enterprises,
    b.bankruptcies_employees
from b
left join dim_m dm on b.municipality = dm.municipality_name
left join dim_i di on b.industry     = di.industry_name
left join dim_y dy on b.year         = dy.year
where b.industry != 'Total'
  and b.industry != 'Industry unknown'
