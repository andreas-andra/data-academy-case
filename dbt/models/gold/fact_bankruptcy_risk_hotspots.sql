-- Bankruptcy Risk Hotspots: municipalities with highest bankruptcy pressure
-- relative to their business base. Designed for the Genie dashboard.
-- Grain: year × municipality
-- Note: yoy_* columns are NULL for 2020 (first year in dataset — no prior year to diff against).
-- hotspot_risk_class uses ntile(4) within each year so thresholds are
-- relative to actual Finnish data, not hardcoded absolute values.

with dim_m as (select * from {{ ref('dim_municipality') }}),
dim_i as (select * from {{ ref('dim_industry') }}),
dim_y as (select * from {{ ref('dim_year') }}),

bankruptcy_totals as (

    -- Use the pre-aggregated 'Total' industry row directly to avoid double-counting.
    -- Summing across individual industry rows would produce the same number but
    -- risks including rounding differences; the Total row is authoritative.
    select
        year,
        municipality,
        bankruptcies_enterprises as total_bankruptcies_enterprises,
        bankruptcies_employees   as total_bankruptcies_employees
    from {{ ref('silver_statfin_bankruptcies') }}
    where industry = 'Total'

),

top_bankruptcy_industry as (

    select
        year,
        municipality,
        industry,
        bankruptcies_enterprises as hotspot_industry_bankruptcies_enterprises,
        bankruptcies_employees   as hotspot_industry_bankruptcies_employees
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
        e.year,
        e.municipality,
        e.establishments_count,
        e.personnel_staff_years,
        p.population,
        p.deaths,
        coalesce(b.total_bankruptcies_enterprises, 0) as total_bankruptcies_enterprises,
        coalesce(b.total_bankruptcies_employees, 0)   as total_bankruptcies_employees,
        t.industry as hotspot_industry,
        coalesce(t.hotspot_industry_bankruptcies_enterprises, 0) as hotspot_industry_bankruptcies_enterprises,
        coalesce(t.hotspot_industry_bankruptcies_employees, 0)   as hotspot_industry_bankruptcies_employees,

        round(
            coalesce(b.total_bankruptcies_enterprises, 0) * 1000.0
            / nullif(e.establishments_count, 0),
            2
        ) as bankruptcies_per_1000_establishments,

        round(
            coalesce(b.total_bankruptcies_employees, 0) * 1000.0
            / nullif(e.personnel_staff_years, 0),
            2
        ) as bankrupt_employees_per_1000_personnel,

        round(
            e.personnel_staff_years / nullif(e.establishments_count, 0),
            2
        ) as personnel_per_establishment,

        round(
            coalesce(b.total_bankruptcies_enterprises, 0) * 10000.0
            / nullif(p.population, 0),
            2
        ) as bankruptcies_per_10000_population

    from {{ ref('silver_statfin_enterprise_establishments') }} e
    left join {{ ref('silver_statfin_population') }} p
        on e.year = p.year
       and e.municipality = p.municipality
    left join bankruptcy_totals b
        on e.year = b.year
       and e.municipality = b.municipality
    left join top_bankruptcy_industry t
        on e.year = t.year
       and e.municipality = t.municipality

),

with_trends as (

    select
        *,
        lag(total_bankruptcies_enterprises) over (
            partition by municipality
            order by year
        ) as prev_total_bankruptcies_enterprises,

        lag(bankruptcies_per_1000_establishments) over (
            partition by municipality
            order by year
        ) as prev_bankruptcies_per_1000_establishments,

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
        round(
            (total_bankruptcies_enterprises - prev_total_bankruptcies_enterprises) * 100.0
            / nullif(prev_total_bankruptcies_enterprises, 0),
            2
        ) as yoy_bankruptcies_pct,

        round(
            (bankruptcies_per_1000_establishments - prev_bankruptcies_per_1000_establishments) * 100.0
            / nullif(prev_bankruptcies_per_1000_establishments, 0),
            2
        ) as yoy_bankruptcy_rate_pct

    from with_trends

),

-- Fixed percentile thresholds derived from the full dataset (all years combined).
-- These are computed once and used as static cutoffs for hotspot_absolute_risk_class,
-- so the classification reflects whether a municipality exceeds a historically-calibrated
-- benchmark — meaning band sizes WILL shift year-over-year if national rates change.
percentile_thresholds as (

    select
        percentile_approx(bankruptcies_per_1000_establishments, 0.75) as p75,
        percentile_approx(bankruptcies_per_1000_establishments, 0.50) as p50,
        percentile_approx(bankruptcies_per_1000_establishments, 0.25) as p25
    from base
    where bankruptcies_per_1000_establishments is not null

),

ranked as (

    select
        *,
        -- ntile(4) partitioned by year ranks municipalities relative to peers in the same year.
        -- Top quartile (ntile=1) = highest bankruptcy rate = 'Severe hotspot'.
        -- Classification reflects relative risk within Finland each year,
        -- so every year always has ~25% in each band. Use hotspot_risk_class for "who is
        -- riskiest this year" comparisons.
        ntile(4) over (
            partition by year
            order by bankruptcies_per_1000_establishments desc
        ) as bankruptcy_rate_ntile,

        -- Fixed threshold classification using dataset-wide percentiles (p25/p50/p75).
        -- Thresholds are calibrated from all years combined and do not shift year-over-year.
        -- Use hotspot_absolute_risk_class for trend analysis — band sizes WILL change
        -- if Finland's overall bankruptcy rate shifts over time.
        case
            when bankruptcies_per_1000_establishments >= (select p75 from percentile_thresholds) then 'Severe hotspot'
            when bankruptcies_per_1000_establishments >= (select p50 from percentile_thresholds) then 'High hotspot'
            when bankruptcies_per_1000_establishments >= (select p25 from percentile_thresholds) then 'Moderate hotspot'
            else 'Low hotspot'
        end as hotspot_absolute_risk_class

    from with_growth

)

select
    dy.year_id,
    dm.municipality_id,
    di.industry_id as hotspot_industry_id,
    r.population,
    r.deaths,
    r.establishments_count,
    r.personnel_staff_years,
    r.total_bankruptcies_enterprises,
    r.total_bankruptcies_employees,
    r.bankruptcies_per_1000_establishments,
    r.bankrupt_employees_per_1000_personnel,
    r.bankruptcies_per_10000_population,
    r.personnel_per_establishment,
    r.yoy_bankruptcies_pct,
    r.yoy_bankruptcy_rate_pct,
    round(r.rolling_3y_avg_bankruptcy_rate, 2) as rolling_3y_avg_bankruptcy_rate,
    r.hotspot_industry_bankruptcies_enterprises,
    r.hotspot_industry_bankruptcies_employees,
    r.bankruptcy_rate_ntile,

    case r.bankruptcy_rate_ntile
        when 1 then 'Severe hotspot'
        when 2 then 'High hotspot'
        when 3 then 'Moderate hotspot'
        when 4 then 'Low hotspot'
    end as hotspot_risk_class,

    -- Cross-year absolute classification — use this for Chart 2 trend analysis
    r.hotspot_absolute_risk_class

from ranked r
left join dim_m dm on r.municipality = dm.municipality_name
left join dim_i di on r.hotspot_industry = di.industry_name
left join dim_y dy on r.year         = dy.year
