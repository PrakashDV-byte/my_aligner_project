#!/bin/bash

###############################################################################
# Regression Script
###############################################################################

set -e

RUNS=${1:-1}

REGRESS_FILE="regressions/regress_list.txt"

BASE_LOG_DIR="logs"

###############################################################################
# Clean Old Data
###############################################################################

echo "[INFO] Cleaning old logs"

rm -rf "$BASE_LOG_DIR"

mkdir -p "$BASE_LOG_DIR"

echo "[INFO] Cleaning old coverage"

rm -rf ucdb

mkdir -p ucdb

###############################################################################
# Compile Once
###############################################################################

echo "[INFO] Compiling Design"

make clean_Questa > /dev/null

mkdir -p "$BASE_LOG_DIR"

make comp > "$BASE_LOG_DIR/compile.log"

echo "[INFO] Compilation Completed"

###############################################################################
# Run Regression
###############################################################################

for ((pass=1; pass<=RUNS; pass++)); do

    LOG_DIR="$BASE_LOG_DIR/run_$pass"

    mkdir -p "$LOG_DIR"

    echo ""
    echo "================================================="
    echo "[INFO] Starting Regression Pass $pass"
    echo "================================================="

    while IFS= read -r TESTNAME || [[ -n "$TESTNAME" ]]; do

        if [[ -z "$TESTNAME" ]]; then
            continue
        fi

        SEED=$(( RANDOM * RANDOM ))

        LOGFILE="$LOG_DIR/sim_${TESTNAME}_${SEED}.log"

        echo "[RUNNING] TEST=$TESTNAME SEED=$SEED"

       make run TESTNAME=$TESTNAME \
	UVM_ARGS="+UVM_TESTNAME=$TESTNAME +sv_seed=$SEED +UVM_MAX_QUIT_COUNT=1 +access+rw -f messages.f" \
	2>&1 | tee "$LOGFILE"
       
    done < "$REGRESS_FILE"

done

###############################################################################
# Generate Coverage
###############################################################################

echo ""
echo "[INFO] Generating Coverage Report"

make report

###############################################################################
# Generate Dashboard
###############################################################################

echo ""
echo "[INFO] Generating Dashboard"

python3 scripts/generate_dashboard.py

###############################################################################
# Done
###############################################################################

echo ""
echo "================================================="
echo "[INFO] REGRESSION COMPLETED"
echo "================================================="
echo ""
echo "Dashboard:"
echo "dashboard/regression.html"
echo ""
echo "Coverage:"
echo "ucdb/coverage_report/index.html"
echo ""
