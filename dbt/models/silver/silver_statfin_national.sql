-- National-level yearly aggregates for Finland, including industry breakdown
-- Sourced directly from WHOLE COUNTRY rows to avoid double-counting

with bankruptcies_national as (
    select * from {{ source('bronze', 'bronze_statfin_bankruptcies') }}
    where `Municipality` = 'WHOLE COUNTRY'
),

enterprises_national as (
    select * from {{ source('bronze', 'bronze_statfin_enterprise_establishments') }}
    where `Municipality` = 'WHOLE COUNTRY'
),

bankruptcies_renamed as (
    select
        cast(`Year` as int)                                                 as year,
        `Industries_luok`                                                   as industry,
        cast(`Bankruptcies instigated, number of enterprises` as int)       as bankruptcies_enterprises,
        cast(`Bankruptcies instigated, number of employees` as int)         as bankruptcies_employees
    from bankruptcies_national
    where `Year` is not null
),

enterprises_renamed as (
    select
        cast(`Year` as int)                                                         as year,
        cast(`Establishments of enterprises (number)` as int)                      as total_establishments,
        cast(`Personnel in establishments of enterprises (staff-years)` as float)  as total_personnel_staff_years
    from enterprises_national
    where `Year` is not null
)

select
    b.year,
    b.industry,
    b.bankruptcies_enterprises,
    b.bankruptcies_employees,
    e.total_establishments,
    e.total_personnel_staff_years
from bankruptcies_renamed b
left join enterprises_renamed e on b.year = e.year
