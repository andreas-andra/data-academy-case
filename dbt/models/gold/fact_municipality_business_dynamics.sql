-- Municipality Business Dynamics: business base growth vs. population trends per municipality per year

with p as (
    select * from {{ ref('silver_statfin_population') }}
),

e as (
    select * from {{ ref('silver_statfin_enterprise_establishments') }}
),

dim_m as (select * from {{ ref('dim_municipality') }}),
dim_y as (select * from {{ ref('dim_year') }}),

base as (

    select
        p.year,
        p.municipality,
        p.population,
        e.establishments_count,
        e.personnel_staff_years,
        round(e.establishments_count * 1000.0 / nullif(p.population, 0), 2)   as establishments_per_1000_population,
        round(e.personnel_staff_years * 1000.0 / nullif(p.population, 0), 2)  as personnel_per_1000_population,
        round(e.personnel_staff_years / nullif(e.establishments_count, 0), 2)  as avg_personnel_per_establishment

    from p
    left join e
        on  p.year         = e.year
        and p.municipality = e.municipality

),

with_lag as (

    select
        *,
        lag(year)                over (partition by municipality order by year) as prev_year,
        lag(establishments_count) over (partition by municipality order by year) as prev_establishments_count,
        lag(personnel_staff_years) over (partition by municipality order by year) as prev_personnel_staff_years,
        lag(population)           over (partition by municipality order by year) as prev_population
    from base

),

with_yoy as (

    select
        *,

        -- NULL when prior row is not exactly year-1 (sparse municipality series guard)
        case when prev_year = year - 1 then
            establishments_count - prev_establishments_count
        end as establishments_yoy_change,

        case when prev_year = year - 1 then
            round(
                (establishments_count - prev_establishments_count) * 100.0
                / nullif(prev_establishments_count, 0), 2
            )
        end as establishments_yoy_pct,

        case when prev_year = year - 1 then
            personnel_staff_years - prev_personnel_staff_years
        end as personnel_yoy_change,

        case when prev_year = year - 1 then
            round(
                (personnel_staff_years - prev_personnel_staff_years) * 100.0
                / nullif(prev_personnel_staff_years, 0), 2
            )
        end as personnel_yoy_pct,

        case when prev_year = year - 1 then
            population - prev_population
        end as population_yoy_change,

        case when prev_year = year - 1 then
            round(
                (population - prev_population) * 100.0
                / nullif(prev_population, 0), 2
            )
        end as population_yoy_pct

    from with_lag

),

with_rolling as (

    select
        *,
        round(
            avg(establishments_yoy_pct) over (
                partition by municipality
                order by year
                rows between 2 preceding and current row
            ), 2
        ) as rolling_3y_avg_establishments_growth_pct
    from with_yoy

),

classified as (

    select
        *,

        case
            when establishments_per_1000_population is not null
            then ntile(4) over (
                partition by year
                order by establishments_per_1000_population desc
            )
        end as density_ntile,

        case
            when establishments_yoy_pct is not null
            then ntile(4) over (
                partition by year
                order by establishments_yoy_pct desc
            )
        end as growth_ntile

    from with_rolling

)

select
    dy.year_id,
    dm.municipality_id,
    c.establishments_count,
    c.personnel_staff_years,
    c.population,
    c.establishments_per_1000_population,
    c.personnel_per_1000_population,
    c.avg_personnel_per_establishment,
    c.establishments_yoy_change,
    c.establishments_yoy_pct,
    c.personnel_yoy_change,
    c.personnel_yoy_pct,
    c.population_yoy_change,
    c.population_yoy_pct,
    c.rolling_3y_avg_establishments_growth_pct,
    case c.density_ntile
        when 1 then 'High density'
        when 2 then 'Above average density'
        when 3 then 'Below average density'
        when 4 then 'Low density'
    end as business_density_class,
    case c.growth_ntile
        when 1 then 'Strong growth'
        when 2 then 'Moderate growth'
        when 3 then 'Moderate decline'
        when 4 then 'Strong decline'
    end as growth_class
from classified c
left join dim_m dm on c.municipality = dm.municipality_name
left join dim_y dy on c.year         = dy.year
