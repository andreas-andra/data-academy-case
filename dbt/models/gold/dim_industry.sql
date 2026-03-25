with industries as (
    select distinct industry
    from {{ ref('silver_statfin_bankruptcies') }}
)

select
    row_number() over (order by industry)   as industry_id,
    industry                                as industry_name
from industries
