# Partner Performance Cube - Quick Start Checklist

**Goal**: Get your dashboard running in 30 minutes

---

## ☐ BEFORE YOU START (5 min)

- [ ] Python 3 installed? 
  ```bash
  python3 --version
  ```
- [ ] Have access to your Tricentis data warehouse (Snowflake/Azure)?
- [ ] Know your GitHub repo location?

---

## ☐ STEP 1: CREATE WORKING DIRECTORY (2 min)

```bash
mkdir -p ~/Downloads/Partner_Dash
cd ~/Downloads/Partner_Dash
```

Verify:
```bash
pwd
# Should show: /Users/YOUR_NAME/Downloads/Partner_Dash
```

---

## ☐ STEP 2: COPY FILES (3 min)

Copy these 4 files from your downloads into `~/Downloads/Partner_Dash/`:

```
Partner_Performance_Cube_Dashboard.html
partner_performance_cube.py
lookups.json
claude_code_refresh.sh
```

Verify all files are there:
```bash
ls -lh ~/Downloads/Partner_Dash/
```

You should see 4 files (+ JA_Look_UP.xlsx if you already have it).

---

## ☐ STEP 3: ADD YOUR LOOKUP FILE (1 min)

Make sure `JA_Look_UP.xlsx` is in `~/Downloads/Partner_Dash/`

```bash
ls ~/Downloads/Partner_Dash/JA_Look_UP.xlsx
```

If missing: Copy it from wherever you have it stored.

---

## ☐ STEP 4: INSTALL PYTHON PACKAGES (2 min)

```bash
pip3 install openpyxl pandas
```

Should see:
```
Successfully installed openpyxl pandas
```

---

## ☐ STEP 5: EXPORT SQL DATA (10 min)

In your SQL client (Snowflake, Azure Data Studio):

1. Run this SQL query:
```sql
SELECT
    Opportunity_ID, Account_ID, Geo, Territory, Product, Source, Tier,
    Stage, Deal_Type, Close_Date, Product_NACV, Discovery_Date,
    Industry, Vertical, Industry_SubCategory,
    Sourcing_Partner, Sourcing_Partner_Tier,
    Influence_Partner, Influence_Partner_Tier,
    Service_Delivery_Partner, Service_Delivery_Partner_Tier
FROM [your_schema].[opportunity_live]
WHERE Close_Date >= '2023-01-01'
    AND NACV_USD != 0
    AND Record_Type IN ('Product', 'Service', 'Platinum Support')
```

2. Export results as **Excel (.xlsx)**

3. Save as: `JA_SQL_EXPORT.xlsx`

4. Move to `~/Downloads/Partner_Dash/`

Verify:
```bash
ls -lh ~/Downloads/Partner_Dash/JA_SQL_EXPORT.xlsx
# Should be a few MB
```

---

## ☐ STEP 6: RUN AGGREGATION (5 min)

```bash
cd ~/Downloads/Partner_Dash
python3 partner_performance_cube.py
```

You should see output like:
```
================================================================================
PARTNER PERFORMANCE CUBE - DATA AGGREGATION
================================================================================

1. Loading partner and team lookups...
   - 2694 partners loaded
   - 29 team mappings loaded

2. Loading and cleaning SQL export...
Loaded 5722 records after filtering future dates

3. Enriching with partner classifications and team mappings...

4. Pre-computing all aggregations...

5. Output saved to dashboard_data.json
   - 1351 filter combinations
   - Ready for embedding in HTML dashboard

================================================================================
COMPLETE
================================================================================
```

If you see errors, check:
- [ ] JA_SQL_EXPORT.xlsx exists and has data
- [ ] Python 3 is installed correctly
- [ ] openpyxl and pandas are installed

---

## ☐ STEP 7: EMBED DATA INTO DASHBOARD (2 min)

```bash
cd ~/Downloads/Partner_Dash
python3 << 'EOF'
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

print("✓ Dashboard updated with latest data")
EOF
```

Verify:
```bash
ls -lh ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html
# Should be ~900KB now (was ~150KB before)
```

---

## ☐ STEP 8: TEST THE DASHBOARD (3 min)

```bash
open ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html
```

You should see:
- [ ] "Partner Performance Cube" header
- [ ] Filter buttons (Geo, Territory, Product, Source)
- [ ] KPI cards with numbers (NACV, Partner Count, Win Rate, etc.)
- [ ] Charts and tables with data

**If you see data:** ✓ Success! Skip to Step 9.

**If dashboard is blank:** Go back to Step 6 and check the Python output for errors.

---

## ☐ STEP 9: COPY TO GITHUB REPO

```bash
# Set your repo path
GITHUB_REPO="$HOME/path/to/your/repo"  # UPDATE THIS

# Copy the updated dashboard
cp ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html "$GITHUB_REPO/"

cd "$GITHUB_REPO"

# Check it's there
ls Partner_Performance_Cube_Dashboard.html
```

---

## ☐ STEP 10: PUSH TO GITHUB

```bash
cd "$GITHUB_REPO"

git add Partner_Performance_Cube_Dashboard.html
git commit -m "Add Partner Performance Cube Dashboard"
git push origin main
```

Your dashboard is now live at your GitHub Pages URL!

---

## ✓ DONE

**Dashboard is live and ready to use.**

### Next Month (Monthly Refresh)

Just repeat Steps 5-10:
1. Export fresh SQL data
2. Run `python3 partner_performance_cube.py`
3. Embed JSON into HTML
4. Push to GitHub

That's it. Everything else stays the same.

---

## TROUBLESHOOTING

### Dashboard opens but shows "No data"
- [ ] Check Python output (Step 6) for errors
- [ ] Verify JA_SQL_EXPORT.xlsx has rows of data
- [ ] Open browser console (F12) and check for JavaScript errors

### "Module not found: openpyxl"
```bash
pip3 install openpyxl pandas
```

### "File not found: JA_SQL_EXPORT.xlsx"
```bash
ls ~/Downloads/Partner_Dash/
# Make sure JA_SQL_EXPORT.xlsx is there
```

### Python script fails
```bash
python3 partner_performance_cube.py 2>&1 | tail -20
# Shows last 20 lines of output to find the error
```

---

## QUESTIONS?

Refer to:
- **Full Setup Guide**: SETUP_INSTRUCTIONS.md
- **Dashboard Features**: README.md
- **Python Script**: partner_performance_cube.py (well-commented)

---

**Estimated Total Time**: ~30 minutes (first time) → ~15 minutes (monthly refresh)
