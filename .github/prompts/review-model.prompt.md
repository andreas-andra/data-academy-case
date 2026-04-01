---
description: "Review a dbt gold model for grain issues, key stability, join correctness, and star-schema compliance"
agent: "data-reviewer"
argument-hint: "Name of the gold model to review, e.g. fact_regional_mortality"
---

Perform a thorough review of the specified gold model. Check:

1. **Grain clarity** — Is the grain obvious from the SQL? Does it match the DBML unique index?
2. **Dimension keys** — Are keys stable (natural or md5)? No `row_number()`?
3. **Join correctness** — All left joins to dimensions? No cross-grain joins?
4. **Industry handling** — Is `Total` handled correctly? No double-counting risk?
5. **Star-schema compliance** — Only FK + measures in fact? Labels in dimensions?
6. **Doc consistency** — Does the SQL match the DBML, star-schema doc, and use-case doc?

Read the model SQL, its corresponding DBML diagram, star-schema doc, and use-case doc. Report findings using the structured review format.
