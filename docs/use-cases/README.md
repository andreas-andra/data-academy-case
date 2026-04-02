# Use Cases

This folder contains business-facing documentation for the gold-layer use cases built on top of the Finnish statistics warehouse.

## Current Use Cases

1. `bankruptcies.md`
   Reusable municipality-industry bankruptcy detail for totals, industry mix, and downstream derived use cases.
2. `bankruptcy-risk-hotspots.md`
   Municipality-level bankruptcy pressure relative to local business base.
3. `bankruptcy-trends-by-industry.md`
   National industry-level view of which sectors drive bankruptcies over time.
4. `finland-economic-health.md`
   Finland-wide annual view of bankruptcies, enterprise base, population, and deaths.
5. `municipality-business-resilience.md`
   Municipality-level composite resilience view across business activity, population, and bankruptcy stress.
6. `municipality-overview.md`
   Wide municipality monitoring view combining demographic, business-base, and bankruptcy totals.
7. `population.md`
   Reusable municipality-level population and business-base fact for demographic context and denominators.
8. `regional-mortality-and-population-change.md`
   Municipality-level mortality and population-change trend view.
9. `industry-labor-impact-bankruptcies.md`
   Industry- and municipality-level view of how many employees are affected by bankruptcy events.
10. `industry-bankruptcy-specialization.md`
   Municipality- and industry-level view of where bankruptcy structure is overrepresented relative to the national pattern.

## Related Dashboard Assets

1. `docs/genie-dashboards/bankruptcies.md`
   Dashboard guidance and prompt assets for the reusable bankruptcy base fact.
2. `docs/genie-dashboards/bankruptcy-risk-hotspots.md`
   Dashboard guidance and prompt assets for the bankruptcy hotspots use case.
3. `docs/genie-dashboards/bankruptcy-trends-by-industry.md`
   Dashboard guidance and prompt assets for the national industry bankruptcy trend use case.
4. `docs/genie-dashboards/finland-economic-health.md`
   Dashboard guidance and prompt assets for the national economic health use case.
5. `docs/genie-dashboards/industry-bankruptcy-specialization.md`
   Dashboard guidance and prompt assets for the specialization use case.
6. `docs/genie-dashboards/industry-labor-impact-bankruptcies.md`
   Dashboard guidance and prompt assets for the labor impact use case.
7. `docs/genie-dashboards/municipality-business-resilience.md`
   Dashboard guidance and prompt assets for the municipality resilience use case.
8. `docs/genie-dashboards/municipality-overview.md`
   Dashboard guidance and prompt assets for the municipality overview use case.
9. `docs/genie-dashboards/population.md`
   Dashboard guidance and prompt assets for the supporting population and business-base fact.
10. `docs/genie-dashboards/regional-mortality-and-population-change.md`
   Dashboard guidance and prompt assets for the mortality and population-change use case.

## Industry Bankruptcy Specialization Bundle

- use case: `industry-bankruptcy-specialization.md`
- fact model: `fact_industry_bankruptcy_specialization`
- diagram source: `docs/diagrams/industry_bankruptcy_specialization.dbml`
- dashboard guidance: `docs/genie-dashboards/industry-bankruptcy-specialization.md`

This bundle documents the municipality-industry specialization use case end to end:

- business question and dashboard guidance in the use-case document
- textbook star-schema structure in the DBML diagram source
- dashboard prompt and chart guidance in the Genie dashboard document

## Suggested Structure For Each Use Case

Each use-case document should answer the following:

1. What business question does it solve?
2. What gold model supports it?
3. What is the grain of the fact table?
4. Which dimensions are used?
5. Which metrics and classifications are important?
6. What should dashboard users watch out for?
7. What example questions can Databricks Genie answer?