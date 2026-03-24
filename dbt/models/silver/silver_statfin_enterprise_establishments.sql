with source as (
    select * from {{ source('bronze', 'bronze_statfin_enterprise_establishments') }}
),

renamed as (
    select
        cast(year as int)                       as year,
        municipality,
        cast(establishments_count as int)       as establishments_count,
        cast(personnel_staff_years as float)    as personnel_staff_years
    from source
    where municipality != 'WHOLE COUNTRY'
      and year is not null
)

select * from renamed
