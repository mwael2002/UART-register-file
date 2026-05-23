
# Default test if TESTNAME is not set externally
if {![info exists TESTNAME]} {
    set TESTNAME "tc_01_reset"
    puts "WARNING: TESTNAME not set, defaulting to $TESTNAME"
}

puts ""
puts "=================================================="
puts " Compiling and Running TEST = $TESTNAME"
puts "=================================================="

# Ensure results directory exists
file mkdir results

# -----------------------------------------------------------------------------
# Step 1: Clean and rebuild the work library
# -----------------------------------------------------------------------------
vlib work
vmap work work

# -----------------------------------------------------------------------------
# Step 2: Compile RTL + Testbench in correct order
# -----------------------------------------------------------------------------
vlog rtl/uart_regfile.sv +cover -covercells  
vlog tb/*.sv
vlog +define+READ_LATENCY_VAL=$READ_LATENCY tb/common_pkg_uart_regfile.sv 
# -----------------------------------------------------------------------------
# Step 3: Redirect transcript to a per-test log file
# -----------------------------------------------------------------------------
set LOGFILE "results/${TESTNAME}.log"
transcript file $LOGFILE

# -----------------------------------------------------------------------------
# Step 4: Launch simulation
#   +TEST=$TESTNAME  -> picked up by $value$plusargs in the testbench
#   run -all         -> run until $finish
#   quit -f          -> force quit after simulation ends
# -----------------------------------------------------------------------------
vsim -voptargs=+acc work.tb_uart_regfile -classdebug -coverage -onfinish stop \
     +TEST=$TESTNAME  \
     -do {
        do scripts/waveform.do
        run -all;
        coverage save ${TESTNAME}_code_cov.ucdb -codeAll -instance dut_uart_regfile
        coverage save ${TESTNAME}_func_cov.ucdb -cvg -directive -assert
     }


transcript file ""