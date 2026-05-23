# =============================================================================
# regression.tcl
# Top-level regression script.
# Runs all tests sequentially and writes a consolidated summary report.
#
# Usage:
#   vsim -c -do scripts/regression.tcl
# =============================================================================

puts ""
puts "=================================================="
puts "         STARTING FULL REGRESSION                "
puts "=================================================="
puts ""

# -----------------------------------------------------------------------------
# Define all tests to run (add new tests here only)
# -----------------------------------------------------------------------------
set tests {
    tc_01_reset
    tc_02_rw_basic
    tc_03_random_wr
    tc_04_random_rd
    tc_05_raw
    tc_06_baud
    tc_07_oob
    tc_08_sticky
    tc_09_rd_busy
    tc_10_wr_busy
    tc_all_tests
}
# -----------------------------------------------------------------------------
# Define READ_LATENCY_MODE 
# -----------------------------------------------------------------------------
set READ_LATENCY 0

# -----------------------------------------------------------------------------
# Prepare the summary report file
# -----------------------------------------------------------------------------
file mkdir results
set SUMMARY_FILE "results/regression_summary.txt"
set fp [open $SUMMARY_FILE "w"]

puts $fp "=================================================="
puts $fp "           REGRESSION SUMMARY REPORT             "
puts $fp "=================================================="
puts $fp "Date : [clock format [clock seconds]]"
puts $fp ""
puts $fp [format "%-25s %s" "TEST NAME" "STATUS"]
puts $fp "--------------------------------------------------"

# -----------------------------------------------------------------------------
# Loop: run each test via run_test.tcl
# -----------------------------------------------------------------------------
set pass_count 0
set fail_count 0

foreach t $tests {
    puts "----------------------------------------------"
    puts " Running: $t"
    puts "----------------------------------------------"

    # Set TESTNAME so run_test.tcl picks it up
    set TESTNAME $t

    # Invoke the run engine
    do scripts/run_test.tcl
    puts $fp [format "%-25s %s" $t "DONE  -> log: results/${t}.log"]
}

puts $fp ""

puts $fp "NOTE: test_oob tests both test_oob_write and test_oob_read"

close $fp

# Build the list of all ucdb files
set code_ucdb_files ""
set func_ucdb_files ""
foreach t $tests {
    set ucdb "${t}_code_cov.ucdb"
    if {[file exists $ucdb]} {
        append code_ucdb_files " $ucdb"
    } else {
        puts "WARNING: $ucdb not found, skipping..."
    }
}

foreach t $tests {
    set ucdb "${t}_func_cov.ucdb"
    if {[file exists $ucdb]} {
        append func_ucdb_files " $ucdb"
    } else {
        puts "WARNING: $ucdb not found, skipping..."
    }
}

# Merge into one unified database
vcover merge merged_code_cov.ucdb {*}$code_ucdb_files 
vcover merge merged_func_cov.ucdb {*}$func_ucdb_files

# Report
vcover report merged_code_cov.ucdb -details -annotate -all -output results/code_coverage_rpt.txt 
vcover report merged_func_cov.ucdb -details -annotate -all -output results/func_coverage_rpt.txt


puts ""
puts "=================================================="
puts " REGRESSION COMPLETE"
puts " Summary : $SUMMARY_FILE"
puts "=================================================="
puts ""

quit -f
