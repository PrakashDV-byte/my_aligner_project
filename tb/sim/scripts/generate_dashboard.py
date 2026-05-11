import os
import re
from datetime import datetime

###############################################################################
# Paths
###############################################################################

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

LOG_ROOT = os.path.join(BASE_DIR, "logs")

DASHBOARD_DIR = os.path.join(BASE_DIR, "dashboard")

os.makedirs(DASHBOARD_DIR, exist_ok=True)

HTML_FILE = os.path.join(DASHBOARD_DIR, "regression.html")

###############################################################################
# Storage
###############################################################################

results = []

processed_tests = set()

###############################################################################
# Collect Regression Logs
###############################################################################

log_files = []

for root, dirs, files in os.walk(LOG_ROOT):

    for file in files:

        #######################################################################
        # Only Parse Regression Simulation Logs
        #######################################################################

        if not file.startswith("sim_"):
            continue

        if not file.endswith(".log"):
            continue

        full_path = os.path.join(root, file)

        #######################################################################
        # Ignore Empty Logs
        #######################################################################

        if os.path.getsize(full_path) == 0:
            continue

        log_files.append(full_path)

###############################################################################
# Parse Logs
###############################################################################

for logfile in sorted(log_files):

    try:

        filename = os.path.basename(logfile)

        match = re.search(r"sim_(.*?)_\d+\.log", filename)

        if not match:
            continue

        testcase = match.group(1)

        #######################################################################
        # Avoid Duplicate Entries
        #######################################################################

        if testcase in processed_tests:
            continue

        processed_tests.add(testcase)

        with open(logfile, "r", errors="ignore") as f:
            content = f.read()

        #######################################################################
        # Extract Errors/Fatals
        #######################################################################

        error_count = 0
        fatal_count = 0

        error_match = re.findall(r'UVM_ERROR\s*:\s*(\d+)', content)

        fatal_match = re.findall(r'UVM_FATAL\s*:\s*(\d+)', content)

        if error_match:
            error_count = int(error_match[-1])

        if fatal_match:
            fatal_count = int(fatal_match[-1])

        #######################################################################
        # PASS / FAIL
        #######################################################################

        status = "PASS"

        if error_count > 0 or fatal_count > 0:
            status = "FAIL"

        #######################################################################
        # Runtime
        #######################################################################

        runtime = "N/A"

        runtime_match = re.search(r'Elapsed time:\s*(.*)', content)

        if runtime_match:
            runtime = runtime_match.group(1)

        #######################################################################
        # Error Details
        #######################################################################

        extracted_errors = []

        for line in content.splitlines():

            if "UVM_ERROR" in line or "UVM_FATAL" in line:

                if "Report Summary" in line:
                    continue

                extracted_errors.append(line.strip())

        #######################################################################
        # Store
        #######################################################################

        results.append({
            "test": testcase,
            "status": status,
            "errors": error_count,
            "fatals": fatal_count,
            "runtime": runtime,
            "messages": extracted_errors
        })

    except Exception as e:

        print(f"[WARNING] Failed parsing {logfile}")
        print(str(e))

###############################################################################
# Statistics
###############################################################################

TOTAL = len(results)

PASS = len([x for x in results if x["status"] == "PASS"])

FAIL = len([x for x in results if x["status"] == "FAIL"])

PASS_PERCENT = 0

if TOTAL > 0:
    PASS_PERCENT = round((PASS / TOTAL) * 100, 2)

###############################################################################
# Date
###############################################################################

DATE = datetime.now().strftime("%d-%m-%Y %H:%M:%S")

###############################################################################
# HTML
###############################################################################

html = f"""
<!DOCTYPE html>
<html>

<head>

<title>UVM Regression Dashboard</title>

<style>

body {{
    font-family: Arial;
    background: #eef2f7;
    padding: 20px;
}}

.header {{
    background: linear-gradient(to right, #1e3c72, #2a5298);
    color: white;
    padding: 20px;
    border-radius: 10px;
}}

.cards {{
    display: flex;
    gap: 20px;
    margin-top: 20px;
    margin-bottom: 20px;
}}

.card {{
    flex: 1;
    background: white;
    padding: 20px;
    border-radius: 10px;
    text-align: center;
    box-shadow: 0px 2px 8px rgba(0,0,0,0.1);
}}

.pass {{
    color: green;
    font-weight: bold;
}}

.fail {{
    color: red;
    font-weight: bold;
}}

table {{
    width: 100%;
    border-collapse: collapse;
    background: white;
    box-shadow: 0px 2px 8px rgba(0,0,0,0.1);
}}

th {{
    background: #1e3c72;
    color: white;
    padding: 12px;
}}

td {{
    padding: 10px;
    border-bottom: 1px solid #ddd;
}}

tr:hover {{
    background: #f5f5f5;
}}

.error-box {{
    background: #fff0f0;
    color: #cc0000;
    padding: 8px;
    border-radius: 5px;
    font-size: 12px;
}}

button {{
    background: #1e3c72;
    color: white;
    border: none;
    padding: 12px 20px;
    border-radius: 8px;
    cursor: pointer;
    margin-bottom: 20px;
}}

button:hover {{
    background: #16325c;
}}

</style>

</head>

<body>

<div class="header">
<h1>UVM Regression Dashboard</h1>
<p>Generated on: {DATE}</p>
</div>

<div class="cards">

<div class="card">
<h3>Total Tests</h3>
<h2>{TOTAL}</h2>
</div>

<div class="card">
<h3>Passed</h3>
<h2 class="pass">{PASS}</h2>
</div>

<div class="card">
<h3>Failed</h3>
<h2 class="fail">{FAIL}</h2>
</div>

<div class="card">
<h3>Pass %</h3>
<h2>{PASS_PERCENT}%</h2>
</div>

</div>

<button onclick="window.open('../ucdb/coverage_report/index.html')">
Open Coverage Report
</button>

<table>

<tr>
<th>Testcase</th>
<th>Status</th>
<th>Errors</th>
<th>Fatals</th>
<th>Runtime</th>
<th>Error Details</th>
</tr>
"""

###############################################################################
# Table Rows
###############################################################################

for r in sorted(results, key=lambda x: x["test"]):

    cls = "pass" if r["status"] == "PASS" else "fail"

    details = "<br>".join(r["messages"])

    if details == "":
        details = "No Errors"

    html += f"""
<tr>
<td>{r['test']}</td>
<td class="{cls}">{r['status']}</td>
<td>{r['errors']}</td>
<td>{r['fatals']}</td>
<td>{r['runtime']}</td>
<td><div class="error-box">{details}</div></td>
</tr>
"""

###############################################################################
# End HTML
###############################################################################

html += """
</table>

</body>
</html>
"""

###############################################################################
# Write File
###############################################################################

with open(HTML_FILE, "w") as f:
    f.write(html)

###############################################################################
# Done
###############################################################################

print("=================================================")
print("Dashboard Generated Successfully")
print("=================================================")
print(f"Total Tests : {TOTAL}")
print(f"Passed      : {PASS}")
print(f"Failed      : {FAIL}")
print(f"HTML        : {HTML_FILE}")
