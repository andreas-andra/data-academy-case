with source as (
    select * from {{ source('bronze', 'bronze_statfin_bankruptcies') }}
),

renamed as (
    select
        cast(`Year` as int)                                                 as year,
        `Municipality`                                                      as municipality,
        `Industries_luok`                                                   as industry,
        cast(`Bankruptcies instigated, number of enterprises` as int)       as bankruptcies_enterprises,
        cast(`Bankruptcies instigated, number of employees` as int)         as bankruptcies_employees
    from source
    where `Municipality` != 'WHOLE COUNTRY'
      and `Year` is not null
)

select * from renamed
