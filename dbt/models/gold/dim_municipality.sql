with municipalities as (
    select distinct municipality
    from {{ ref('silver_statfin_population') }}
)

select
    row_number() over (order by municipality)   as municipality_id,
    municipality                                as municipality_name
from municipalities
