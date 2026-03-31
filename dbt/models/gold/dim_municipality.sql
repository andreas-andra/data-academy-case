with municipalities as (
    select municipality
    from {{ ref('silver_statfin_population') }}

    union

    select municipality
    from {{ ref('silver_statfin_enterprise_establishments') }}

    union

    select municipality
    from {{ ref('silver_statfin_bankruptcies') }}
)

select
    md5(lower(trim(municipality)))              as municipality_id,
    municipality                                as municipality_name
from municipalities
