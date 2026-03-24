with source as (
    select * from {{ source('bronze', 'bronze_statfin_bankruptcies') }}
),

renamed as (
    select
        cast(year as int)                       as year,
        municipality,
        industries_luok                         as industry,
        cast(bankruptcies_enterprises as int)   as bankruptcies_enterprises,
        cast(bankruptcies_employees as int)     as bankruptcies_employees
    from source
    where municipality != 'WHOLE COUNTRY'
      and year is not null
)

select * from renamed
