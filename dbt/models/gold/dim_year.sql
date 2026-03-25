with years as (
    select distinct year
    from {{ ref('silver_statfin_population') }}
)

select
    year,
    year                                as year_label,
    case
        when year between 2020 and 2021 then 'COVID Period'
        when year between 2022 and 2023 then 'Post-COVID Recovery'
        else 'Recent'
    end                                 as period_label
from years
order by year
