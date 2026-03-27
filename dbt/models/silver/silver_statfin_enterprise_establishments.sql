with source as (
    select * from {{ source('bronze', 'bronze_statfin_enterprise_establishments') }}
),

renamed as (
    select
        cast(`Year` as int)                                                         as year,
        `Municipality`                                                              as municipality,
        cast(nullif(`Establishments of enterprises (number)`, '.')  as int)                      as establishments_count,
        cast(nullif(`Personnel in establishments of enterprises (staff-years)`, '.') as float)  as personnel_staff_years
    from source
    where `Municipality` != 'WHOLE COUNTRY'
      and `Year` is not null
)

select * from renamed
