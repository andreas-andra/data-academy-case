with bankruptcy_totals as (

    select
        year,
        municipality,
        sum(bankruptcies_enterprises) as total_bankruptcies_enterprises,
        sum(bankruptcies_employees) as total_bankruptcies_employees
    from {{ ref('silver_statfin_bankruptcies') }}
    group by year, municipality

),

top_bankruptcy_industry as (

    select
        year,
        municipality,
        industry as top_bankruptcy_industry,
        bankruptcies_enterprises as top_industry_bankruptcies_enterprises,
        bankruptcies_employees as top_industry_bankruptcies_employees
    from (
        select
            year,
            municipality,
            industry,
            bankruptcies_enterprises,
            bankruptcies_employees,
            row_number() over (
                partition by year, municipality
                order by bankruptcies_enterprises desc, bankruptcies_employees desc, industry
            ) as rn
        from {{ ref('silver_statfin_bankruptcies') }}
        where industry != 'Total'
          and industry != 'Industry unknown'
    ) ranked
    where rn = 1

),

base as (

    select
        p.year,
        p.municipality,
        p.population,
        p.deaths,
        e.establishments_count,
        e.personnel_staff_years,
        coalesce(b.total_bankruptcies_enterprises, 0) as total_bankruptcies_enterprises,
        coalesce(b.total_bankruptcies_employees, 0) as total_bankruptcies_employees,
        t.top_bankruptcy_industry,
        coalesce(t.top_industry_bankruptcies_enterprises, 0) as top_industry_bankruptcies_enterprises,
        coalesce(t.top_industry_bankruptcies_employees, 0) as top_industry_bankruptcies_employees,

        round(coalesce(b.total_bankruptcies_enterprises, 0) * 1000.0 / nullif(e.establishments_count, 0), 2)
            as bankruptcies_per_1000_establishments,

        round(coalesce(b.total_bankruptcies_employees, 0) * 1000.0 / nullif(e.personnel_staff_years, 0), 2)
            as bankrupt_employees_per_1000_personnel,

        round(e.personnel_staff_years / nullif(e.establishments_count, 0), 2)
            as personnel_per_establishment,

        round(p.deaths * 1000.0 / nullif(p.population, 0), 2)
            as deaths_per_1000_population

    from {{ ref('silver_statfin_population') }} p
    inner join {{ ref('silver_statfin_enterprise_establishments') }} e
        on p.year = e.year
       and p.municipality = e.municipality
    left join bankruptcy_totals b
        on p.year = b.year
       and p.municipality = b.municipality
    left join top_bankruptcy_industry t
        on p.year = t.year
       and p.municipality = t.municipality

),

with_trends as (

    select
        *,

        lag(population) over (
            partition by municipality
            order by year
        ) as prev_population,

        lag(establishments_count) over (
            partition by municipality
            order by year
        ) as prev_establishments_count,

        lag(personnel_staff_years) over (
            partition by municipality
            order by year
        ) as prev_personnel_staff_years,

        lag(total_bankruptcies_enterprises) over (
            partition by municipality
            order by year
        ) as prev_total_bankruptcies_enterprises,

        avg(total_bankruptcies_enterprises) over (
            partition by municipality
            order by year
            rows between 2 preceding and current row
        ) as rolling_3y_avg_bankruptcies,

        avg(bankruptcies_per_1000_establishments) over (
            partition by municipality
            order by year
            rows between 2 preceding and current row
        ) as rolling_3y_avg_bankruptcy_rate

    from base

),

with_growth as (

    select
        *,

        round((population - prev_population) * 100.0 / nullif(prev_population, 0), 2)
            as yoy_population_pct,

        round((establishments_count - prev_establishments_count) * 100.0 / nullif(prev_establishments_count, 0), 2)
            as yoy_establishments_pct,

        round((personnel_staff_years - prev_personnel_staff_years) * 100.0 / nullif(prev_personnel_staff_years, 0), 2)
            as yoy_personnel_pct,

        round((total_bankruptcies_enterprises - prev_total_bankruptcies_enterprises) * 100.0 / nullif(prev_total_bankruptcies_enterprises, 0), 2)
            as yoy_bankruptcies_pct

    from with_trends

),

scored as (

    select
        *,

        percent_rank() over (
            partition by year
            order by bankruptcies_per_1000_establishments
        ) as pr_bankruptcy_rate,

        percent_rank() over (
            partition by year
            order by yoy_establishments_pct
        ) as pr_establishment_growth,

        percent_rank() over (
            partition by year
            order by yoy_personnel_pct
        ) as pr_personnel_growth,

        percent_rank() over (
            partition by year
            order by yoy_population_pct
        ) as pr_population_growth,

        percent_rank() over (
            partition by year
            order by deaths_per_1000_population desc
        ) as pr_death_pressure

    from with_growth

),

final as (

    select
        *,
        -- Resilience score: weighted sum of percent_rank signals, scaled to 0–100.
        -- Weights are heuristic (not empirically validated):
        --   35% low bankruptcy rate, 20% establishment growth, 20% personnel growth,
        --   15% population growth, 10% low death pressure.
        -- These were chosen as reasonable starting assumptions and should be
        -- revisited if domain expertise or regression analysis suggests better values.
        round(
            (
                (1 - pr_bankruptcy_rate) * 0.35 +
                pr_establishment_growth  * 0.20 +
                pr_personnel_growth      * 0.20 +
                pr_population_growth     * 0.15 +
                pr_death_pressure        * 0.10
            ) * 100,
            2
        ) as resilience_score
    from scored

)

select
    year,
    municipality,

    population,
    deaths,
    establishments_count,
    personnel_staff_years,

    total_bankruptcies_enterprises,
    total_bankruptcies_employees,

    bankruptcies_per_1000_establishments,
    bankrupt_employees_per_1000_personnel,
    personnel_per_establishment,
    deaths_per_1000_population,

    yoy_population_pct,
    yoy_establishments_pct,
    yoy_personnel_pct,
    yoy_bankruptcies_pct,

    round(rolling_3y_avg_bankruptcies, 2)    as rolling_3y_avg_bankruptcies,
    round(rolling_3y_avg_bankruptcy_rate, 2) as rolling_3y_avg_bankruptcy_rate,

    top_bankruptcy_industry,
    top_industry_bankruptcies_enterprises,
    top_industry_bankruptcies_employees,

    resilience_score,

    case
        when resilience_score >= 80 then 'Strong'
        when resilience_score >= 60 then 'Stable'
        when resilience_score >= 40 then 'Watchlist'
        else 'Fragile'
    end as municipality_business_class

from final