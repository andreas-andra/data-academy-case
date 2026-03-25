-- Bankruptcies by industry per year at national level (excludes Total row)

with national as (
    select * from {{ ref('silver_statfin_national') }}
),

dim_y as (select * from {{ ref('dim_year') }}),
dim_i as (select * from {{ ref('dim_industry') }})

select
    n.year,
    dy.period_label,
    n.industry,
    di.industry_id,
    n.bankruptcies_enterprises,
    n.bankruptcies_employees,
    round(n.bankruptcies_enterprises / nullif(sum(n.bankruptcies_enterprises) over (partition by n.year), 0) * 100, 2)
        as share_of_total_pct
from national n
left join dim_y dy on n.year = dy.year
left join dim_i di on n.industry = di.industry_name
where n.industry != 'Total'
  and n.industry != 'Industry unknown'
order by n.year, n.bankruptcies_enterprises desc
