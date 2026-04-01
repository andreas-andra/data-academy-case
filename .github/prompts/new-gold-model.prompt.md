---
description: "Generate a gold dbt model SQL file from a star-schema doc or DBML diagram"
agent: "dbt-modeler"
argument-hint: "The star-schema doc or DBML to implement, e.g. star-schema-regional-mortality.md"
---

Create a new gold dbt model based on the provided star-schema documentation or DBML diagram.

## Steps

1. Read the referenced documentation to understand:
   - Fact table grain
   - Required dimensions and their keys
   - Measures and derived columns

2. Identify which silver model(s) provide the source data by checking `dbt/models/silver/`

3. Write the SQL following gold model conventions:
   - CTE aliases: source as short alias, dimensions as `dim_m`, `dim_i`, `dim_y`
   - Left joins to all referenced dimensions
   - Only foreign keys and measures in the SELECT
   - `table` materialization (set in `dbt_project.yml`)

4. Place the file at `dbt/models/gold/fact_<name>.sql`

## Reference

Check existing gold models for style: [fact_bankruptcies.sql](dbt/models/gold/fact_bankruptcies.sql)
