`timescale 1ns/10ps

module tb_uart_regfile;
    
    import common_pkg_uart_regfile::*;
    import cov_pkg_uart_regfile::*;
    import tasks_pkg_uart_reg_file::*;   

    logic clk, rst_n;

    // Host Interface signals
    logic                          wr_en;
    logic [$clog2(N_REGS)-1:0]    wr_addr;
    logic [DATA_W-1:0]             wr_data;
    logic [$clog2(N_REGS)-1:0]    rd_addr_a;
    logic [$clog2(N_REGS)-1:0]    rd_addr_b;
    logic [DATA_W-1:0]             rd_data_a;
    logic [DATA_W-1:0]             rd_data_b;
    logic                          rd_valid_a;
    logic                          rd_valid_b;

    // System Interface signals
    logic                          uart_busy;
    logic [1:0]                    uart_error;
    logic                          update_ok;
    logic                          uart_enable;
    logic [2:0]                    uart_mode;
    logic [15:0]                   uart_rate;

    uart_regfile_class #(.DATA_W(DATA_W),.N_REGS(N_REGS)) uart_regfile_class_cvg = new();

    // Clock generation
    always begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // =========================================================
    // Stimulus
    // =========================================================
    initial begin
        string testname;

        // Step 1 - Initialize & Reset
        initialize(wr_en, wr_addr, rd_addr_a, rd_addr_b, wr_data, uart_busy, uart_error, update_ok);
        reset_assertion(clk, rst_n);

        // Step 2 - Get test name
        if (!$value$plusargs("TEST=%s", testname))
            testname = "tc_01_reset";

        $display("==================================================");
        $display(" Running TEST = %s", testname);
        $display("==================================================");

        // Step 3 - Dispatch
        run_selected_test(testname,
            clk, rst_n,
            wr_en, wr_addr, wr_data,
            rd_addr_a, rd_addr_b, rd_data_a, rd_data_b, rd_valid_a, rd_valid_b,
            uart_busy, uart_error, update_ok,
            uart_enable, uart_mode, uart_rate
        );

        // Step 4 - Reset assertion after every test
        reset_assertion(clk, rst_n);

        $display("TEST %s DONE", testname);
        $stop;
    end

    // =========================================================
    // Coverage sampling
    // =========================================================
    always @(posedge clk) begin
        uart_regfile_class_cvg.rst_n      = rst_n;
        uart_regfile_class_cvg.wr_en      = wr_en;
        uart_regfile_class_cvg.uart_busy  = uart_busy;
        uart_regfile_class_cvg.uart_error = uart_error;
        uart_regfile_class_cvg.wr_addr    = wr_addr;
        uart_regfile_class_cvg.rd_addr_a  = rd_addr_a;
        uart_regfile_class_cvg.rd_addr_b  = rd_addr_b;
    end

    always @(negedge clk) begin
        uart_regfile_class_cvg.cvr_gp.sample();
    end

    // =========================================================
    // DUT instantiation
    // =========================================================
    uart_regfile #(.DATA_W(DATA_W),.N_REGS(N_REGS),.READ_LATENCY(READ_LATENCY))
    dut_uart_regfile (
        .clk        (clk),       .rst_n      (rst_n),
        .wr_en      (wr_en),     .wr_addr    (wr_addr),
        .wr_data    (wr_data),   .rd_addr_a  (rd_addr_a),
        .rd_addr_b  (rd_addr_b), .rd_data_a  (rd_data_a),
        .rd_data_b  (rd_data_b), .rd_valid_a (rd_valid_a),
        .rd_valid_b (rd_valid_b),.uart_busy  (uart_busy),
        .uart_error (uart_error),.update_ok  (update_ok),
        .uart_enable(uart_enable),.uart_mode (uart_mode),
        .uart_rate  (uart_rate)
    );

    bind dut_uart_regfile asser_uart_regfile  #(.DATA_W(DATA_W),.N_REGS(N_REGS),.READ_LATENCY(READ_LATENCY)) asser_tb(.*);

endmodule