# Use Cases

This folder contains business-facing documentation for the gold-layer use cases built on top of the Finnish statistics warehouse.

## Current Use Cases

1. `bankruptcy-risk-hotspots.md`
   Municipality-level bankruptcy pressure relative to local business base.
2. `industry-labor-impact-bankruptcies.md`
   Industry- and municipality-level view of how many employees are affected by bankruptcy events.

## Planned Use Cases

1. Municipality Business Resilience
2. Finland Economic Health
3. Municipality Overview
4. Regional Mortality and Population Change

## Related Dashboard Assets

1. `docs/Industry Labor Impact Ban.pdf`
   Genie-generated dashboard for the labor impact use case, validated against the gold model.

## Suggested Structure For Each Use Case

Each use-case document should answer the following:

1. What business question does it solve?
2. What gold model supports it?
3. What is the grain of the fact table?
4. Which dimensions are used?
5. Which metrics and classifications are important?
6. What should dashboard users watch out for?
7. What example questions can Databricks Genie answer?