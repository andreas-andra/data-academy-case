with industries as (
    select distinct industry
    from {{ ref('silver_statfin_bankruptcies') }}
)

select
    md5(lower(trim(industry)))              as industry_id,
    industry                                as industry_name
from industries
