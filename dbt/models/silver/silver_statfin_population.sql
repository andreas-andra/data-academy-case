with source as (
    select * from {{ source('bronze', 'bronze_statfin_population') }}
),

renamed as (
    select
        cast(`Year` as int)         as year,
        `Area`                      as municipality,
        cast(`Population` as int)   as population
    from source
    where `Area` != 'WHOLE COUNTRY'
      and `Year` is not null
)

select * from renamed
