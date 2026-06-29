# Partner Performance Cube Dashboard

Interactive dashboard for analyzing Tricentis partner contribution, sourcing, and performance metrics.

## Overview

The Partner Performance Cube is a static-site dashboard that pre-computes all partner aggregations at build time and serves them as a single HTML file. No backend, no database at runtime—everything is pre-calculated and embedded as JSON.

### Architecture

```
SQL Query (Snowflake/Azure)
    ↓
    CSV/Excel Export
    ↓
partner_performance_cube.py (Python aggregation)
    ↓
    Computes: NACV, win rates, deal counts by:
    - Geo × Territory × Product × Source × Deal Type × Partner × Month
    ↓
    Outputs: dashboard_data.json (~1.2MB)
    ↓
    Embedded in HTML → Partner_Performance_Cube_Dashboard.html
    ↓
GitHub Pages (static hosting)
```

## Files

- **Partner_Performance_Cube_Dashboard.html** – The complete dashboard (self-contained, ~900KB). Open in any browser.
- **partner_performance_cube.py** – Python script to aggregate SFDC export data.
- **lookups.json** – Partner classifications and team mappings (extracted from JA_Look_UP.xlsx).
- **dashboard_data.json.gz** – Compressed pre-computed aggregations (reference; embedded in HTML).

## Setup & Refresh

### Step 1: Export Data from SQL

Run your SQL query against the Tricentis data warehouse:

```sql
SELECT
    Opportunity_ID, Account_ID, Geo, Territory, Product, Source, Tier,
    Stage, Deal Type, Close_Date, Product_NACV, Discovery_Date,
    Industry, Vertical, Industry_SubCategory,
    Sourcing_Partner, Sourcing_Partner_Tier,
    Influence_Partner, Influence_Partner_Tier,
    Service_Delivery_Partner, Service_Delivery_Partner_Tier
FROM [your_schema].[opportunity_live]
WHERE Close_Date >= '2023-01-01'
    AND NACV != 0
    -- [your filters]
```

Export as **JA_SQL_EXPORT.xlsx** (Excel format).

### Step 2: Update Lookups (if needed)

If partner classifications or team mappings change, update **JA_Look_UP.xlsx** in your data source, then extract to **lookups.json**:

```python
# Extract from JA_Look_UP.xlsx and regenerate lookups.json
python3 -c "
import openpyxl, json
# [See partner_performance_cube.py for extraction logic]
"
```

### Step 3: Run Aggregation

```bash
python3 partner_performance_cube.py
```

This will:
1. Load the SQL export (JA_SQL_EXPORT.xlsx)
2. Apply partner/team lookups
3. Clean dates (drop 2099+, handle NULLs)
4. Pre-compute all 1,300+ filter combinations
5. Output dashboard_data.json

### Step 4: Generate Dashboard

Embed the JSON into the HTML:

```python
import json

with open('dashboard_data.json', 'r') as f:
    data = json.load(f)

with open('Partner_Performance_Cube_Dashboard.html', 'r') as f:
    html = f.read()

html = html.replace(
    'const DASHBOARD_DATA = DASHEMBEDDATA;',
    f'const DASHBOARD_DATA = {json.dumps(data)};'
)

with open('Partner_Performance_Cube_Dashboard.html', 'w') as f:
    f.write(html)
```

### Step 5: Push to GitHub Pages

```bash
git add Partner_Performance_Cube_Dashboard.html
git commit -m "Update partner performance data - $(date +%Y-%m-%d)"
git push origin main
```

The dashboard is now live at your GitHub Pages URL.

## Features

### Filters
- **Geo**: AMS, EMEA, APAC
- **Territory**: Select from your booking territories
- **Product**: Tosca, Testim, NeoLoad, qTest, etc.
- **Source**: Partner Sourced, Sales Sourced, Marketing Sourced, etc.
- **Partner View**: Toggle between account name and top-level parent

### Views
1. **Overview**: KPI cards + charts (contribution type, tier, top 10 partners)
2. **Sourcing Partners**: Originated deals only
3. **Influence Partners**: Influenced deals
4. **Service Partners**: Resale/MSP deals

### Metrics
- NACV (sum)
- Deal Count
- Win Rate
- Avg Deal Size
- Contribution Type (Originated, Influenced, Resale/MSP)
- Partner Tier (Other Partner, Preferred Partner, GSI)

## Data Flow

### Partner Enrichment

Each partner (Sourcing, Influence, Service) is enriched from **JA_Look_UP.xlsx**:

```json
{
  "0018c000030lG62AAE": {
    "name": "10Pearls",
    "top_level": "10Pearls",
    "tier": "Other Partner",
    "geo": "AMS"
  }
}
```

### Territory Mapping

Booking teams are mapped to final aggregated territories via **Sheet1** in JA_Look_UP.xlsx:

```
"AMS Core East Canada" → "AMS Core East Canada"
"AMS Core LATAM" → "AMS Core East LATAM"
"AMS West LATAM" → "AMS Core East LATAM"
```

## Troubleshooting

### "No data after filtering"
- Check that your SQL export includes the date range you're filtering on
- Verify partner names match exactly between your SFDC export and JA_Look_UP.xlsx

### Dashboard is slow
- The HTML is ~900KB (1.2MB uncompressed JSON). This is normal.
- On modern browsers, it loads instantly.
- If deploying to GitHub Pages, gzip compression is automatic.

### Partner tiers showing "Unclassified"
- The partner SFDC Account ID doesn't exist in JA_Look_UP.xlsx
- Either add the partner to the lookup, or it will remain unclassified

## Configuration

### Hardcoded Lookups

Partner classifications and team mappings are hardcoded in `lookups.json`. To update:

1. Edit your **JA_Look_UP.xlsx** source file
2. Re-run the extraction logic in `partner_performance_cube.py`
3. Commit updated **lookups.json** to repo

Future: These can be moved to a SQL table if they become dynamic.

## Performance Notes

- **Build time**: 10-30 seconds (depends on data volume)
- **Dashboard load**: <1 second on modern browsers
- **Browser compatibility**: All modern browsers (Chrome, Firefox, Safari, Edge)
- **Offline-capable**: Yes, the HTML is fully self-contained after load

## Support

Questions or issues? Check:
- SQL export is properly formatted (use the provided query)
- Partner lookups exist in JA_Look_UP.xlsx
- Python dependencies: `openpyxl`, `pandas` (pip install if needed)

---

**Last Generated**: See "generated_at" in dashboard_data.json or check your GitHub commit timestamp.
