
# All interface signals
add wave *

# A1 group
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A11
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A12
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A13
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A14

# A2 group
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A21
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A23
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A24
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A25
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A26
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A27
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A28

# A3 group
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A31
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A32

# A4 group
if {$READ_LATENCY==1} {
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A4_READ_LATENCY_1/A41
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A4_READ_LATENCY_1/A42
} else {
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A4_READ_LATENCY_0/A41
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A4_READ_LATENCY_0/A42
}
# A5
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A5

# A6
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A6

# A7
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A7

# A8 group
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A81
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A82
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A83

# A9 group
if {$READ_LATENCY==1} {
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A9_READ_LATENCY_1/A91
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A9_READ_LATENCY_1/A92
} else {
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A9_READ_LATENCY_0/A91
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A9_READ_LATENCY_0/A92
}
# A10
add wave sim:/tb_uart_regfile/dut_uart_regfile/asser_tb/A10