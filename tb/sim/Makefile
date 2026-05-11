###############################################################################
# Makefile for UVM Aligner Regression Environment
# Simulator : Mentor QuestaSim
###############################################################################

###############################################################################
# Directories
###############################################################################

RTL_DIR        = ../../rtl
TB_TOP_DIR     = ../top

LOG_DIR        = logs
UCDB_DIR       = ucdb
DASHBOARD_DIR  = dashboard

###############################################################################
# Source Files
###############################################################################

TOP_SRCS = \
$(RTL_DIR)/design.sv \
$(TB_TOP_DIR)/testbench.sv

###############################################################################
# Default Test
###############################################################################

DEFAULT_TEST = cfs_algn_apb_tests_mapped_unmapped
TESTNAME ?= $(DEFAULT_TEST)

###############################################################################
# Simulation Library
###############################################################################

WORKLIB = work

###############################################################################
# UVM Arguments
###############################################################################

UVM_ARGS = \
+UVM_TESTNAME=$(TESTNAME) \
+UVM_MAX_QUIT_COUNT=1 \
+access+rw \
-f messages.f \
-sv_seed random

###############################################################################
# Coverage / DO Files
###############################################################################

TOGGLE_DO = ../../tb/sim/toggle_exclude.do

###############################################################################
# Logs
###############################################################################

COMP_LOG   = $(LOG_DIR)/compile.log
SIM_LOG    = $(LOG_DIR)/$(TESTNAME).log
TRANSCRIPT = $(LOG_DIR)/$(TESTNAME)_transcript.log

###############################################################################
# Coverage
###############################################################################

UCDB_FILE = $(UCDB_DIR)/$(TESTNAME).ucdb

###############################################################################
# Default
###############################################################################

all: clean comp run

###############################################################################
# Create Directories
###############################################################################

dirs:
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(UCDB_DIR)
	@mkdir -p $(DASHBOARD_DIR)

###############################################################################
# Compile
###############################################################################

comp: dirs
	@echo "================================================="
	@echo "[INFO] Compiling Design and Testbench"
	@echo "================================================="

	@rm -rf $(WORKLIB)

	@vlib $(WORKLIB) | tee $(COMP_LOG)

	@vmap $(WORKLIB) $(WORKLIB) | tee -a $(COMP_LOG)

	@vlog -sv \
	-cover bcest \
	-work $(WORKLIB) \
	$(TOP_SRCS) \
	+acc \
	+define+QUESTA \
	+incdir+$(RTL_DIR) \
	+incdir+$(TB_TOP_DIR) \
	| tee -a $(COMP_LOG) | tee -a $(TRANSCRIPT)

	@echo ""
	@echo "[INFO] Compilation Completed"
	@echo ""

###############################################################################
# Run Simulation
###############################################################################

run:
	@mkdir -p $(LOG_DIR)
	@mkdir -p $(UCDB_DIR)

	@echo "================================================="
	@echo "[INFO] Running TESTNAME=$(TESTNAME)"
	@echo "================================================="

	@vsim -coverage -c work.testbench $(UVM_ARGS) \
	-do "do $(TOGGLE_DO); coverage save -onexit $(UCDB_FILE); run -all; quit;" \
	2>&1 | tee $(SIM_LOG) | tee -a $(TRANSCRIPT)

	@echo ""
	@echo "[INFO] Simulation Completed"
	@echo ""

###############################################################################
# GUI Run
###############################################################################

grun:
	@mkdir -p $(LOG_DIR)

	@vsim -coverage work.testbench $(UVM_ARGS) \
	-do "do wave.do; run -all;" \
	2>&1 | tee $(SIM_LOG) | tee -a $(TRANSCRIPT) &

###############################################################################
# Regression
###############################################################################

regress:
	@chmod +x regressions/run_regression.sh
	@./regressions/run_regression.sh $(RUNS)

###############################################################################
# Merge Coverage
###############################################################################

merge_cov:
	@echo "[INFO] Cleaning old merged coverage"

	@rm -f $(UCDB_DIR)/merged.ucdb

	@echo "[INFO] Merging UCDB Files"

	@vcover merge \
	$(UCDB_DIR)/merged.ucdb \
	$(shell find $(UCDB_DIR) -name '*.ucdb' ! -name 'merged.ucdb')

###############################################################################
# Coverage Report
###############################################################################

report: merge_cov
	@echo "[INFO] Generating HTML Coverage Report"

	@rm -rf $(UCDB_DIR)/coverage_report

	@vcover report \
	-html \
	-output $(UCDB_DIR)/coverage_report \
	-details \
	-verbose \
	$(UCDB_DIR)/merged.ucdb

	@echo "[INFO] Generating Text Coverage Summary"

	@vcover report \
	-details \
	-verbose \
	$(UCDB_DIR)/merged.ucdb \
	> $(UCDB_DIR)/coverage_summary.txt

	@echo ""
	@echo "[INFO] Coverage Report Generated"
	@echo ""
	@echo "HTML Report:"
	@echo "ucdb/coverage_report/index.html"
	@echo ""
	@echo "Text Summary:"
	@echo "ucdb/coverage_summary.txt"
	@echo ""
###############################################################################
# Dashboard
###############################################################################

dashboard:
	@python3 scripts/generate_dashboard.py

###############################################################################
# Full Flow
###############################################################################

full_regress:
	@make regress RUNS=$(RUNS)
	@make report
	@make dashboard

	@echo ""
	@echo "================================================="
	@echo "[INFO] FULL REGRESSION COMPLETED"
	@echo "================================================="
	@echo ""
	@echo "Dashboard:"
	@echo "dashboard/regression.html"
	@echo ""
	@echo "Coverage:"
	@echo "ucdb/coverage_report/index.html"
	@echo ""

###############################################################################
# Clean Questa
###############################################################################

clean_Questa:
	@rm -rf work
	@rm -rf transcript
	@rm -rf *.log
	@rm -rf vsim.wlf
	@rm -rf modelsim.ini
	@rm -rf dump.vcd

###############################################################################
# Clean Logs
###############################################################################

clean_logs:
	@rm -rf $(LOG_DIR)

###############################################################################
# Clean Coverage
###############################################################################

clean_cov:
	@rm -rf $(UCDB_DIR)

###############################################################################
# Clean Dashboard
###############################################################################

clean_dashboard:
	@rm -rf $(DASHBOARD_DIR)

###############################################################################
# Full Clean
###############################################################################

clean: clean_Questa clean_logs clean_cov clean_dashboard

###############################################################################
# Help
###############################################################################

help:
	@echo ""
	@echo "make comp"
	@echo "make run TESTNAME=<test>"
	@echo "make grun TESTNAME=<test>"
	@echo "make regress RUNS=1"
	@echo "make report"
	@echo "make dashboard"
	@echo "make full_regress RUNS=1"
	@echo ""

###############################################################################
# Phony Targets
###############################################################################

.PHONY: \
all \
dirs \
comp \
run \
grun \
regress \
merge_cov \
report \
dashboard \
full_regress \
clean
