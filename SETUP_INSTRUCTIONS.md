# Partner Performance Cube Dashboard
## Setup & Refresh Instructions

**Location**: `~/Downloads/Partner_Dash/`

---

## INITIAL SETUP

### Step 1: Create the Working Directory

```bash
mkdir -p ~/Downloads/Partner_Dash
cd ~/Downloads/Partner_Dash
```

### Step 2: Copy Files from This Chat

Copy these 4 files into `~/Downloads/Partner_Dash/`:

1. **Partner_Performance_Cube_Dashboard.html** (889KB)
2. **partner_performance_cube.py** (11KB)
3. **lookups.json** (438KB)
4. **claude_code_refresh.sh** (this script)

Verify they're all there:
```bash
ls -lh ~/Downloads/Partner_Dash/
```

You should see:
```
Partner_Performance_Cube_Dashboard.html
partner_performance_cube.py
lookups.json
claude_code_refresh.sh
JA_Look_UP.xlsx (your source file)
JA_SQL_EXPORT.xlsx (will be here after step 3)
```

### Step 3: Get Your Data Files

You need two Excel files in `~/Downloads/Partner_Dash/`:

#### **JA_Look_UP.xlsx**
- Your partner classification and team mapping source file
- Should already be in Downloads/Partner_Dash
- Contains two sheets:
  - "Partner Look UP" – Account IDs, names, classifications, tiers
  - "Sheet1" – Team/territory mappings

#### **JA_SQL_EXPORT.xlsx**
- Fresh export from your Tricentis data warehouse
- Use the SQL query provided in README.md
- Export as Excel (.xlsx)
- Save to: `~/Downloads/Partner_Dash/JA_SQL_EXPORT.xlsx`

### Step 4: Update Python Dependencies

```bash
pip install openpyxl pandas
```

---

## MONTHLY REFRESH WORKFLOW

### Full Automated Refresh (Recommended)

**Every time you have fresh data:**

#### 1. Export new SQL data
```bash
# In your SQL client (Snowflake, Azure Data Studio, etc.):
# Run the SQL query from README.md
# Export results as: JA_SQL_EXPORT.xlsx
# Save to: ~/Downloads/Partner_Dash/JA_SQL_EXPORT.xlsx
```

#### 2. Run the refresh script using Claude Code

Open Claude Code and run:

```bash
cd ~/Downloads/Partner_Dash
bash claude_code_refresh.sh
```

**What this does:**
1. ✓ Validates input files exist
2. ✓ Runs Python aggregation (5-10 seconds)
3. ✓ Generates dashboard_data.json
4. ✓ Embeds JSON into HTML
5. ✓ Pushes to GitHub (if configured)

**Done.** Your dashboard is updated.

---

### Manual Step-by-Step (if script fails)

#### Step 1: Place SQL export in the directory

```bash
# Verify the file exists:
ls -lh ~/Downloads/Partner_Dash/JA_SQL_EXPORT.xlsx
```

#### Step 2: Run Python aggregation

```bash
cd ~/Downloads/Partner_Dash
python3 partner_performance_cube.py
```

**Output:**
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

Check the file was created:
```bash
ls -lh ~/Downloads/Partner_Dash/dashboard_data.json
```

#### Step 3: Embed JSON into HTML

```bash
cd ~/Downloads/Partner_Dash
python3 << 'EOF'
import json

# Read JSON
with open('dashboard_data.json', 'r') as f:
    dashboard_data = json.load(f)

# Read HTML
with open('Partner_Performance_Cube_Dashboard.html', 'r') as f:
    html = f.read()

# Embed JSON
html = html.replace(
    'const DASHBOARD_DATA = DASHEMBEDDATA;',
    f'const DASHBOARD_DATA = {json.dumps(dashboard_data)};'
)

# Write back
with open('Partner_Performance_Cube_Dashboard.html', 'w') as f:
    f.write(html)

print("✓ Dashboard updated with latest data")
print(f"✓ File size: {len(html) / (1024*1024):.1f} MB")
EOF
```

#### Step 4: Verify the update

Open the dashboard in your browser:
```bash
open ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html
```

You should see data populated. Check the "generated_at" timestamp in the browser console or by inspecting the page.

#### Step 5: Copy to GitHub repo and push

```bash
# Set your GitHub repo path
GITHUB_REPO="$HOME/path/to/your/tricentis-dashboards-repo"

# Copy the updated dashboard
cp ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html "$GITHUB_REPO/"

# Push to GitHub
cd "$GITHUB_REPO"
git add Partner_Performance_Cube_Dashboard.html
git commit -m "Update partner performance data - $(date +%Y-%m-%d)"
git push origin main
```

---

## USING CLAUDE CODE FOR AUTOMATION

### Setup Claude Code (One time)

1. Install Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

2. Create a `.clauderc` file in `~/Downloads/Partner_Dash/`:
```bash
cat > ~/Downloads/Partner_Dash/.clauderc << 'EOF'
{
  "workingDirectory": "~/Downloads/Partner_Dash",
  "allowedCommands": [
    "python3",
    "bash",
    "ls",
    "pwd",
    "git"
  ]
}
EOF
```

### Run Monthly Refresh with Claude Code

```bash
claude-code run ~/Downloads/Partner_Dash/claude_code_refresh.sh
```

Or open Claude Code in your terminal and paste this command.

---

## DIRECTORY STRUCTURE

After setup, your directory should look like:

```
~/Downloads/Partner_Dash/
├── Partner_Performance_Cube_Dashboard.html    # The live dashboard (updated monthly)
├── partner_performance_cube.py                # Aggregation script
├── lookups.json                               # Partner classifications (hardcoded)
├── claude_code_refresh.sh                     # Automated refresh script
├── JA_SQL_EXPORT.xlsx                         # Fresh SQL export (monthly)
├── JA_Look_UP.xlsx                            # Partner lookup reference
└── dashboard_data.json                        # Generated JSON (temporary)
```

---

## TROUBLESHOOTING

### "No data showing in dashboard"

1. Check SQL export has data:
```bash
python3 << 'EOF'
import openpyxl
wb = openpyxl.load_workbook('JA_SQL_EXPORT.xlsx')
ws = wb['Sheet1']
print(f"Rows in export: {ws.max_row - 1}")
EOF
```

2. Check aggregation ran successfully:
```bash
ls -lh dashboard_data.json
# Should be ~1.2 MB
```

3. Verify HTML was embedded:
```bash
grep -c "const DASHBOARD_DATA = {" Partner_Performance_Cube_Dashboard.html
# Should return 1
```

### "Python: command not found"

Install Python 3:
```bash
# macOS
brew install python3

# Ubuntu/Linux
sudo apt-get install python3

# Windows (use WSL or download from python.org)
```

### "Module not found: openpyxl"

```bash
pip3 install openpyxl pandas --user
```

### "JA_SQL_EXPORT.xlsx not found"

Make sure you:
1. Exported the SQL query from Snowflake/Azure
2. Saved it as Excel (.xlsx) not CSV
3. Named it exactly: `JA_SQL_EXPORT.xlsx`
4. Placed it in: `~/Downloads/Partner_Dash/`

Verify:
```bash
ls -lh ~/Downloads/Partner_Dash/JA_SQL_EXPORT.xlsx
```

### Dashboard appears but no filters work

- Check browser console for JavaScript errors (F12 → Console)
- Verify dashboard_data.json was properly embedded (look for `const DASHBOARD_DATA = {` in HTML source)
- Try refreshing the page (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows/Linux)

---

## TIMELINE & CADENCE

**Monthly Refresh** (recommended):
1. Export fresh SQL data (5 min)
2. Run refresh script (10 min)
3. Push to GitHub (1 min)
4. **Total: ~15 minutes**

**Quarterly Updates** (optional):
- Update partner classifications if needed
- Regenerate lookups.json
- Commit to GitHub repo

---

## DASHBOARD FEATURES AT A GLANCE

Once live, your dashboard provides:

- **4 Views**: Overview + Sourcing/Influence/Service partners
- **Filters**: Geo, Territory, Product, Source
- **Toggle**: Switch between account names & top-level parents
- **KPIs**: Total NACV, Partner Count, Avg Deal Size, Win Rate
- **Charts**: Contribution breakdown, tier analysis, top 10 partners
- **Tables**: Detailed partner metrics with win rates

---

## GETTING HELP

If you get stuck:

1. Check this guide first
2. See TROUBLESHOOTING section above
3. Verify all input files exist with `ls -lh ~/Downloads/Partner_Dash/`
4. Check Python script output for specific error messages
5. Inspect browser console (F12) for dashboard errors

---

## FILE REFERENCES

- **SQL Query**: See README.md in this repo
- **Partner Lookups**: JA_Look_UP.xlsx (your source)
- **Team Mappings**: JA_Look_UP.xlsx Sheet1
- **Dashboard Features**: Open Partner_Performance_Cube_Dashboard.html in browser

---

**Last Updated**: June 29, 2026
**Dashboard Version**: 1.0
**Data Records**: 5,722
**Pre-computed Combinations**: 1,351
