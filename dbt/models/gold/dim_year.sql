with years as (
    select distinct year from {{ ref('silver_statfin_population') }}
    union
    select distinct year from {{ ref('silver_statfin_bankruptcies') }}
    union
    select distinct year from {{ ref('silver_statfin_enterprise_establishments') }}
    union
    select distinct year from {{ ref('silver_statfin_national') }}
)

select
    year                            as year_id,
    year
from years
order by year
