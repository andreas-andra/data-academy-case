---
description: "Scaffold a complete new use case: gold dbt model, use-case doc, star-schema doc, and DBML diagram"
agent: "agent"
argument-hint: "Describe the business question and which silver sources to use"
---

Create a new use case for the analytics warehouse. This requires four deliverables:

## Steps

1. **Understand the grain** — What is the primary business question? What grain does it need (year, municipality, industry, or a combination)?

2. **Write the gold model** — Create `dbt/models/gold/fact_<name>.sql` following the project convention:
   - CTE aliases: `b`, `dim_m`, `dim_i`, `dim_y`
   - Left joins to shared dimensions
   - Foreign keys + measures only in the fact
   - Reference existing silver models via `{{ ref('silver_statfin_<source>') }}`

3. **Write the use-case doc** — Create `docs/use-cases/<name>.md` with:
   - Business Question
   - Business Value
   - Gold Model reference (name, grain, schema style)
   - Dimensions used
   - Core Metrics
   - Example Genie Questions (at least 5 natural language questions)

4. **Write the star-schema doc** — Create `docs/architecture/star-schema-<name>.md` with:
   - Fact table name and grain
   - Dimension references
   - Why it's a star schema
   - Diagram reference

5. **Write the DBML diagram** — Create `docs/diagrams/<name>.dbml` with:
   - Dimension table definitions (only those used)
   - Fact table with all columns, types, and unique index
   - Ref lines for all foreign keys

## Reference

Check existing examples for style:
- [Gold model](dbt/models/gold/fact_bankruptcy_risk_hotspots.sql)
- [Use-case doc](docs/use-cases/bankruptcy-risk-hotspots.md)
- [Star-schema doc](docs/architecture/star-schema-bankruptcy-hotspots.md)
- [DBML diagram](docs/diagrams/bankruptcy_risk_hotspots.dbml)
