# Partner Performance Cube Dashboard - Complete Setup Guide
## Location: ~/Downloads/Partner_Dash/

---

## WHAT YOU'RE BUILDING

An **interactive analytics dashboard** that shows partner sourcing, influence, and service delivery metrics.

- **Type**: Static HTML file (no backend)
- **Data**: Pre-computed from your SQL export
- **Hosting**: GitHub Pages
- **Location**: `~/Downloads/Partner_Dash/`
- **Time to Deploy**: 30 minutes (first time), 15 minutes (monthly refresh)

---

## FILES YOU HAVE

All these files are ready in your Downloads folder. Copy them into `~/Downloads/Partner_Dash/`:

| File | Purpose | Size |
|------|---------|------|
| **QUICK_START.md** | ← **START HERE** – 10-step checklist | 6KB |
| **SETUP_INSTRUCTIONS.md** | Full detailed guide with troubleshooting | 9KB |
| **Partner_Performance_Cube_Dashboard.html** | The live dashboard (embed data here) | 889KB |
| **partner_performance_cube.py** | Python aggregation script | 11KB |
| **lookups.json** | Partner tier/classification data | 438KB |
| **claude_code_refresh.sh** | Automated monthly refresh script | 5KB |
| **README.md** | Technical documentation | 6KB |

---

## THE 30-MINUTE SETUP

### 1. Create your working directory
```bash
mkdir -p ~/Downloads/Partner_Dash
cd ~/Downloads/Partner_Dash
```

### 2. Copy the 7 files above into `~/Downloads/Partner_Dash/`

### 3. Make sure you have your data files
- `JA_SQL_EXPORT.xlsx` – Your Tricentis data (export from SQL)
- `JA_Look_UP.xlsx` – Partner lookups (you already have this)

### 4. Install Python packages
```bash
pip3 install openpyxl pandas
```

### 5. Export your SQL query
In Snowflake/Azure Data Studio, run the query from README.md and export as `JA_SQL_EXPORT.xlsx` to `~/Downloads/Partner_Dash/`

### 6. Run the aggregation
```bash
cd ~/Downloads/Partner_Dash
python3 partner_performance_cube.py
```

This generates `dashboard_data.json` (~1.2MB)

### 7. Embed the data into the dashboard
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

print("✓ Dashboard updated")
EOF
```

### 8. Test the dashboard
```bash
open ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html
```

Should see data, filters, and charts.

### 9. Copy to your GitHub repo
```bash
cp ~/Downloads/Partner_Dash/Partner_Performance_Cube_Dashboard.html /path/to/your/repo/
```

### 10. Push to GitHub
```bash
cd /path/to/your/repo
git add Partner_Performance_Cube_Dashboard.html
git commit -m "Add Partner Performance Cube"
git push origin main
```

**Done.** Your dashboard is live.

---

## MONTHLY REFRESH (After First Setup)

Once you have it live, monthly updates take **15 minutes**:

```bash
# 1. Export fresh SQL data → save as JA_SQL_EXPORT.xlsx in ~/Downloads/Partner_Dash/
# 2. Run:
cd ~/Downloads/Partner_Dash
python3 partner_performance_cube.py

# 3. Embed (the 7-line Python snippet from Step 7 above)

# 4. Push to GitHub (Steps 9-10)
```

Or use the automated script:
```bash
cd ~/Downloads/Partner_Dash
bash claude_code_refresh.sh
```

---

## DETAILED GUIDES

### For Step-by-Step Instructions
→ **Read: QUICK_START.md**  
- 10-item checklist
- Clear yes/no boxes
- ~20 minutes

### For Full Documentation  
→ **Read: SETUP_INSTRUCTIONS.md**
- Complete troubleshooting
- Multiple ways to refresh
- Directory structure
- Timeline and cadence

### For Technical Details
→ **Read: README.md**
- Architecture explanation
- How the Python aggregation works
- Data flow diagrams
- Configuration notes

### For Automation
→ **Use: claude_code_refresh.sh**
- Runs the entire workflow
- Use with Claude Code terminal
- Handles file validation
- Pushes to GitHub automatically

---

## DIRECTORY LAYOUT

After setup, your folder looks like:

```
~/Downloads/Partner_Dash/
├── Partner_Performance_Cube_Dashboard.html    ← The live dashboard
├── partner_performance_cube.py                ← Aggregation script
├── lookups.json                               ← Partner data
├── claude_code_refresh.sh                     ← Auto-refresh script
├── QUICK_START.md                             ← This checklist
├── SETUP_INSTRUCTIONS.md                      ← Full guide
├── README.md                                  ← Tech docs
├── JA_SQL_EXPORT.xlsx                         ← Your data (monthly)
├── JA_Look_UP.xlsx                            ← Partner reference
└── dashboard_data.json                        ← Generated JSON (temp)
```

---

## DASHBOARD FEATURES

Once live, users get:

### Filters
- **Geo**: AMS, EMEA, APAC
- **Territory**: All 30+ territories
- **Product**: Tosca, Testim, NeoLoad, qTest, etc.
- **Source**: Partner/Sales/Marketing sourced
- **Partner View**: Toggle account name ↔ top-level parent

### Views
1. **Overview** – KPIs + contribution charts + top partners
2. **Sourcing Partners** – "Originated" deals only
3. **Influence Partners** – "Influenced" deals
4. **Service Partners** – "Resale/MSP" deals

### Metrics
- Total NACV (sum)
- Deal count
- Win rate (%)
- Average deal size
- Contribution type breakdown

### Visualizations
- Contribution type breakdown (pie)
- Partner tier distribution (pie)
- Top 10 partners (bar chart)
- Sortable partner tables

---

## TROUBLESHOOTING QUICK ANSWERS

### "Dashboard appears but no data"
- Check Step 6 Python output for errors
- Verify JA_SQL_EXPORT.xlsx has rows
- Make sure openpyxl/pandas installed

### "Python: command not found"
```bash
brew install python3  # macOS
sudo apt install python3  # Linux
# Windows: Download from python.org
```

### "ModuleNotFoundError: openpyxl"
```bash
pip3 install openpyxl pandas
```

### "JA_SQL_EXPORT.xlsx not found"
```bash
ls ~/Downloads/Partner_Dash/
# File must be there before running Python
```

### "GitHub push fails"
```bash
cd /path/to/your/repo
git status
# Check which files need to be added
git add Partner_Performance_Cube_Dashboard.html
git commit -m "Update partner dashboard"
git push origin main
```

---

## WHICH GUIDE DO I READ?

**You are here:** This summary (START HERE)

**Next step:**
- Quick? → Read **QUICK_START.md** (5 min checklist)
- Thorough? → Read **SETUP_INSTRUCTIONS.md** (full guide)
- Just run it? → Run `bash claude_code_refresh.sh`

---

## KEY POINTS

✅ **All files are ready** – No coding required, just follow steps  
✅ **Works offline** – HTML is fully self-contained  
✅ **30-minute setup** – Then 15-minute monthly refreshes  
✅ **Modern design** – Tricentis brand colors, responsive layout  
✅ **Flexible partners** – Toggle between account names and rolled-up parents  
✅ **Pre-computed** – 1,351 filter combinations computed at build time  

---

## NEXT ACTION

1. **Download all 7 files** from your Downloads folder
2. **Create ~/Downloads/Partner_Dash/** directory
3. **Copy files there**
4. **Read QUICK_START.md** (the 10-step checklist)
5. **Follow the steps** (30 minutes)
6. **Dashboard is live** on GitHub Pages

---

## SUPPORT

Stuck? Check in this order:
1. QUICK_START.md – Is there a checkbox for your issue?
2. SETUP_INSTRUCTIONS.md – Detailed troubleshooting section
3. README.md – Technical architecture and data flow
4. Check your Python output – Most errors explained there

---

**Ready? Start with QUICK_START.md below** ↓

---

*Last Updated: June 29, 2026*  
*Dashboard Version: 1.0*  
*Location: ~/Downloads/Partner_Dash/*
