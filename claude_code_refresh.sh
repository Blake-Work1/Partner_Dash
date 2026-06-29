#!/bin/bash
# Partner Performance Cube Dashboard - Claude Code Workflow
# Location: ~/Downloads/Partner_Dash/
# 
# This script automates the entire refresh workflow:
# 1. Load SQL export
# 2. Run Python aggregation
# 3. Embed JSON into HTML
# 4. Push to GitHub Pages

set -e  # Exit on error

# ==============================================================================
# CONFIGURATION
# ==============================================================================

WORK_DIR="$HOME/Downloads/Partner_Dash"
SCRIPT_NAME="partner_performance_cube.py"
SQL_EXPORT="JA_SQL_EXPORT.xlsx"
LOOKUPS="JA_Look_UP.xlsx"
DASHBOARD_HTML="Partner_Performance_Cube_Dashboard.html"
DASHBOARD_JSON="dashboard_data.json"

# GitHub repo (set this to your repo)
GITHUB_REPO="$HOME/path/to/your/github/repo"  # UPDATE THIS

echo "================================================================================"
echo "PARTNER PERFORMANCE CUBE - REFRESH WORKFLOW"
echo "================================================================================"
echo "Working Directory: $WORK_DIR"
echo ""

# ==============================================================================
# STEP 1: VALIDATE INPUT FILES
# ==============================================================================

echo "Step 1: Validating input files..."

if [ ! -f "$WORK_DIR/$SQL_EXPORT" ]; then
    echo "ERROR: $SQL_EXPORT not found in $WORK_DIR"
    echo "Please export your SQL query and save as: $WORK_DIR/$SQL_EXPORT"
    exit 1
fi

if [ ! -f "$WORK_DIR/$LOOKUPS" ]; then
    echo "ERROR: $LOOKUPS not found in $WORK_DIR"
    echo "Please ensure partner lookups file exists at: $WORK_DIR/$LOOKUPS"
    exit 1
fi

if [ ! -f "$WORK_DIR/$SCRIPT_NAME" ]; then
    echo "ERROR: $SCRIPT_NAME not found in $WORK_DIR"
    echo "Please ensure the Python script exists at: $WORK_DIR/$SCRIPT_NAME"
    exit 1
fi

echo "✓ All input files validated"
echo ""

# ==============================================================================
# STEP 2: RUN PYTHON AGGREGATION
# ==============================================================================

echo "Step 2: Running Python aggregation..."
echo ""

cd "$WORK_DIR"

python3 "$SCRIPT_NAME" 2>&1

if [ $? -ne 0 ]; then
    echo "ERROR: Python aggregation failed"
    exit 1
fi

if [ ! -f "$WORK_DIR/$DASHBOARD_JSON" ]; then
    echo "ERROR: dashboard_data.json was not generated"
    exit 1
fi

echo ""
echo "✓ Python aggregation complete"
echo "  Output: $WORK_DIR/$DASHBOARD_JSON"
echo ""

# ==============================================================================
# STEP 3: EMBED JSON INTO HTML
# ==============================================================================

echo "Step 3: Embedding JSON into HTML dashboard..."
echo ""

python3 << 'EMBED_SCRIPT'
import json
import os

work_dir = os.path.expanduser("~/Downloads/Partner_Dash")
json_file = os.path.join(work_dir, "dashboard_data.json")
html_file = os.path.join(work_dir, "Partner_Performance_Cube_Dashboard.html")

# Read JSON
with open(json_file, 'r') as f:
    dashboard_data = json.load(f)

# Read HTML
with open(html_file, 'r') as f:
    html_content = f.read()

# Embed JSON
html_content = html_content.replace(
    'const DASHBOARD_DATA = DASHEMBEDDATA;',
    f'const DASHBOARD_DATA = {json.dumps(dashboard_data)};'
)

# Write back
with open(html_file, 'w') as f:
    f.write(html_content)

file_size = len(html_content) / (1024 * 1024)
print(f"✓ JSON embedded into HTML")
print(f"  File size: {file_size:.1f} MB")
print(f"  Output: {html_file}")

EMBED_SCRIPT

echo ""
echo "✓ Dashboard HTML updated with latest data"
echo ""

# ==============================================================================
# STEP 4: PUSH TO GITHUB (MANUAL STEP)
# ==============================================================================

echo "Step 4: Pushing to GitHub..."
echo ""

if [ ! -d "$GITHUB_REPO" ]; then
    echo "ERROR: GitHub repo not found at: $GITHUB_REPO"
    echo ""
    echo "To complete the push manually:"
    echo "  1. Copy Partner_Performance_Cube_Dashboard.html to your GitHub repo"
    echo "  2. Run: git add Partner_Performance_Cube_Dashboard.html"
    echo "  3. Run: git commit -m 'Update partner performance data - $(date +%Y-%m-%d)'"
    echo "  4. Run: git push origin main"
    exit 0
fi

cd "$GITHUB_REPO"

# Check if file exists in repo
if [ ! -f "$GITHUB_REPO/$DASHBOARD_HTML" ]; then
    echo "ERROR: Dashboard HTML not found in GitHub repo"
    echo "Please ensure $DASHBOARD_HTML exists in: $GITHUB_REPO"
    exit 1
fi

# Copy updated dashboard to repo
cp "$WORK_DIR/$DASHBOARD_HTML" "$GITHUB_REPO/$DASHBOARD_HTML"

# Commit and push
git add "$DASHBOARD_HTML"
git commit -m "Update partner performance data - $(date +%Y-%m-%d)"
git push origin main

echo "✓ Pushed to GitHub successfully"
echo ""

# ==============================================================================
# SUMMARY
# ==============================================================================

echo "================================================================================"
echo "REFRESH COMPLETE"
echo "================================================================================"
echo ""
echo "Dashboard updated:"
echo "  • Data aggregated from: $WORK_DIR/$SQL_EXPORT"
echo "  • JSON generated: $WORK_DIR/$DASHBOARD_JSON"
echo "  • HTML updated: $WORK_DIR/$DASHBOARD_HTML"
echo "  • Pushed to GitHub: $(date)"
echo ""
echo "Dashboard is now live at your GitHub Pages URL"
echo ""
