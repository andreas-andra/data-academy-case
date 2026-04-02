# Databricks Lakeview Dashboards

This folder stores exported Lakeview dashboard definitions (`.lvdash.json`) for version control and reproducible deployment.

## Workflow

### 1. Create a Dashboard
Use the Genie prompts in `docs/genie-dashboards/` to generate SQL queries, then build the dashboard in Databricks UI.

### 2. Export
From the dashboard in Databricks UI:
1. Click the **three-dot menu** (⋯) → **Export**
2. Save the `.lvdash.json` file to this folder
3. Name it to match the use case: `<use-case-name>.lvdash.json`

### 3. Version Control
```bash
git add databricks/dashboards/<name>.lvdash.json
git commit -m "Export <name> Lakeview dashboard"
```

### 4. Deploy via Databricks Asset Bundles
```bash
cd /path/to/repo
databricks bundle deploy --target dev
```

This deploys all dashboards defined in `databricks.yml` to your Databricks workspace.

## Expected Dashboards

| Dashboard | Source Prompt | Gold Model |
|-----------|-------------|------------|
| `bankruptcies.lvdash.json` | `docs/genie-dashboards/bankruptcies.md` | `fact_bankruptcies` |
| `bankruptcy-trends-by-industry.lvdash.json` | `docs/genie-dashboards/bankruptcy-trends-by-industry.md` | `fact_bankruptcies_by_industry` |
| `bankruptcy-risk-hotspots.lvdash.json` | `docs/genie-dashboards/bankruptcy-risk-hotspots.md` | `fact_bankruptcy_risk_hotspots` |
| `finland-economic-health.lvdash.json` | `docs/genie-dashboards/finland-economic-health.md` | `fact_finland_economic_health` |
| `industry-bankruptcy-specialization.lvdash.json` | `docs/genie-dashboards/industry-bankruptcy-specialization.md` | `fact_industry_bankruptcy_specialization` |
| `industry-labor-impact-bankruptcies.lvdash.json` | `docs/genie-dashboards/industry-labor-impact-bankruptcies.md` | `fact_industry_labor_impact_bankruptcies` |
| `municipality-overview.lvdash.json` | `docs/genie-dashboards/municipality-overview.md` | `fact_municipality_overview` |
| `municipality-business-resilience.lvdash.json` | `docs/genie-dashboards/municipality-business-resilience.md` | `fact_municipality_resilience` |
| `population.lvdash.json` | `docs/genie-dashboards/population.md` | `fact_population` |
| `regional-mortality.lvdash.json` | `docs/genie-dashboards/regional-mortality-and-population-change.md` | `fact_regional_mortality` |

## Notes

- Dashboard JSON files may contain workspace-specific IDs (warehouse ID, catalog). The `databricks.yml` bundle config handles environment-specific overrides.
- Always re-export after making changes in the UI to keep the JSON in sync.
