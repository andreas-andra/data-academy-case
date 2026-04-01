# Use Cases

This folder contains business-facing documentation for the gold-layer use cases built on top of the Finnish statistics warehouse.

## Current Use Cases

1. `bankruptcy-risk-hotspots.md`
   Municipality-level bankruptcy pressure relative to local business base.
2. `bankruptcy-trends-by-industry.md`
   National industry-level view of which sectors drive bankruptcies over time.
3. `finland-economic-health.md`
   Finland-wide annual view of bankruptcies, enterprise base, population, and deaths.
4. `municipality-business-resilience.md`
   Municipality-level composite resilience view across business activity, population, and bankruptcy stress.
5. `municipality-overview.md`
   Wide municipality monitoring view combining demographic, business-base, and bankruptcy totals.
6. `regional-mortality-and-population-change.md`
   Municipality-level mortality and population-change trend view.
7. `industry-labor-impact-bankruptcies.md`
   Industry- and municipality-level view of how many employees are affected by bankruptcy events.
8. `industry-bankruptcy-specialization.md`
   Municipality- and industry-level view of where bankruptcy structure is overrepresented relative to the national pattern.

## Supporting Facts Documented In Architecture

- `fact_bankruptcies`
- `fact_population`

These are reusable gold facts with architecture docs and diagram sources, but they are not currently framed as standalone dashboard use cases.

## Related Dashboard Assets

1. `docs/Industry Labor Impact Ban.pdf`
   Genie-generated dashboard for the labor impact use case, validated against the gold model.
2. `docs/Industry Bankruptcy Speci.pdf`
   Genie-generated dashboard for the specialization use case, validated against the gold model.

## Industry Bankruptcy Specialization Bundle

- use case: `industry-bankruptcy-specialization.md`
- fact model: `fact_industry_bankruptcy_specialization`
- diagram source: `docs/diagrams/industry_bankruptcy_specialization.dbml`
- rendered diagram: `docs/diagrams/industry_bankruptcy_specialization.png`
- dashboard artifact: `docs/Industry Bankruptcy Speci.pdf`

This bundle documents the municipality-industry specialization use case end to end:

- business question and dashboard guidance in the use-case document
- textbook star-schema structure in the DBML and rendered diagram
- validated Genie dashboard output in the PDF asset

## Suggested Structure For Each Use Case

Each use-case document should answer the following:

1. What business question does it solve?
2. What gold model supports it?
3. What is the grain of the fact table?
4. Which dimensions are used?
5. Which metrics and classifications are important?
6. What should dashboard users watch out for?
7. What example questions can Databricks Genie answer?