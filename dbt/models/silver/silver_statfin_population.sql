with source as (
    select * from {{ source('bronze', 'bronze_statfin_population') }}
),

renamed as (
    select
        cast(year as int)           as year,
        area                        as municipality,
        cast(population as int)     as population
    from source
    where area != 'WHOLE COUNTRY'
      and year is not null
)

select * from renamed
