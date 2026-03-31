# Modeling Decisions

## Purpose

This document captures the key modeling decisions made in the gold layer so another engineer can understand not just the final structure, but also the reasoning behind it.

## 1. Clear Fact Grain Over Convenience Joins

The project uses separate fact tables for different grains instead of trying to merge all use cases into one large fact.

Examples:

- `fact_bankruptcies`: year x municipality x industry
- `fact_population`: year x municipality
- `fact_finland_economic_health`: year
- `fact_bankruptcy_risk_hotspots`: year x municipality
- `fact_municipality_resilience`: year x municipality

Why:

- prevents fan-out joins
- keeps aggregations trustworthy
- makes model intent explicit
- gives Genie safer, more purpose-built tables to query

## 2. Avoiding Fan-Out Joins

One early issue was caused by joining municipality-level facts to a bankruptcy fact that also had industry grain.

Problem:

- `fact_bankruptcies` contains one row per `year x municipality x industry`
- `fact_population` contains one row per `year x municipality`
- joining these directly duplicates establishment counts across industry rows

Outcome:

- inflated counts such as obviously wrong establishment totals

Decision:

- never join facts of different grain directly for business reporting
- instead, create gold models at the reporting grain needed by the use case

## 3. Handling `industry = 'Total'`

The bankruptcy source contains both:

- detailed industry rows
- an aggregate `industry = 'Total'` row

This creates a double-counting risk.

Decision:

- for municipality or national totals, use the authoritative `industry = 'Total'` row directly
- do not sum detailed rows together with `Total`
- for top-industry logic, explicitly exclude `Total` and `Industry unknown`

Applied in:

- `fact_bankruptcy_risk_hotspots`
- `fact_municipality_resilience`
- national economic health logic

## 4. Stable Dimension Keys

Initial dimension keys used `row_number()`.

Problem:

- `row_number()` is rebuild-dependent
- adding or reordering source values can shift IDs
- downstream foreign keys become unstable across rebuilds

Decision:

- `dim_year`: use natural key, `year_id = year`
- `dim_municipality`: use stable hash key from municipality name
- `dim_industry`: use stable hash key from industry name

Why:

- stable across rebuilds
- easy to reason about in documentation and diagrams
- better aligned with dimensional modeling best practice than transient row numbers

## 5. Shared Dimensions In Gold Facts

Gold facts now expose explicit dimension keys such as:

- `year_id`
- `municipality_id`
- `industry_id` where appropriate

Decision:

- if a fact has a year grain, expose `year_id`
- if a fact has municipality grain, expose `municipality_id`
- use descriptive attributes only as analyst-friendly convenience columns, not as a replacement for keys

Why:

- makes the star schema real in code, not just in diagrams
- supports consistent joins in downstream tools
- improves technical credibility of the warehouse design

## 6. Municipality Dimension Coverage

Initially `dim_municipality` was built only from the population source.

Problem:

- enterprise data included municipality values not present in population
- this risked missing dimension keys for some fact rows

Decision:

- build `dim_municipality` from the union of municipality values found across population, enterprise, and bankruptcy sources

Why:

- gives fuller coverage of municipality-bearing facts
- avoids accidental `NULL` foreign keys due to incomplete dimension sourcing

## 7. Relative vs Absolute Hotspot Classification

The Bankruptcy Risk Hotspots use case needs two different ranking concepts.

### Relative classification

- `hotspot_risk_class`
- based on `ntile(4)` partitioned by year

Use for:

- who is riskiest within the latest year

Limitation:

- each year always has roughly 25 percent of municipalities in each band
- not suitable for time-series distribution analysis

### Absolute classification

- `hotspot_absolute_risk_class`
- based on fixed thresholds derived from dataset-wide percentiles

Use for:

- whether overall risk distribution shifts across years

Why both exist:

- one supports within-year ranking
- one supports cross-year trend interpretation

## 8. Removing Misleading Period Labels

An earlier version of the year dimension used labels like:

- `COVID Period`
- `Post-COVID Recovery`
- `Recent`

Decision:

- remove these labels entirely from the codebase

Why:

- they imposed an interpretation not appropriate for the Finnish economic context
- they added opinionated semantics to a shared dimension
- for engineering-facing analytics models, neutral time dimensions are safer and more reusable

## 9. Missing Value Handling

The enterprise establishments source uses `.` as a missing-value sentinel for some dissolved or merged municipalities.

Decision:

- convert `.` explicitly with `NULLIF(..., '.')` before casting

Why:

- avoids relying on implicit engine behavior
- makes the missing-value logic explicit in the silver layer
- keeps downstream null handling predictable

## 10. Heuristic Scores Must Be Documented

The resilience model contains a weighted composite score.

Decision:

- keep the score, but document clearly that the weights are heuristic rather than empirically validated

Why:

- avoids presenting the score as objective truth
- makes it easier for future engineers or domain experts to revisit the assumptions

## Summary

The guiding principle across the gold layer is:

- clear grain
- explicit keys
- reusable dimensions
- defensive handling of source quirks
- minimal hidden semantics

This matters especially because the warehouse is queried not only by humans, but also by AI tooling such as Databricks Genie, which benefits from well-structured, low-ambiguity gold models.