`timescale 1ns/10ps

package tasks_pkg_uart_reg_file;  

    import common_pkg_uart_regfile::*;
    
    localparam PORTA   = 0, PORTB = 1;
    localparam ADDR_W = $clog2(N_REGS);

    localparam ERROR_AND_BUSY_BITS_REG_ADDR=2;
    localparam ENABLE_AND_MODE_REG_ADDR=0;
    localparam BAUD_RATE_REG_ADDR=1;
    localparam ILLEGAL_ADDR =3;
    localparam BAUD_RATE_DEFAULT_VALUE=9600;
    localparam BUSY_BIT=0;


    // =================================================================================
    // Dispatcher task 
    // =================================================================================
    task automatic run_selected_test(
        input string testname,
        // Clock & Reset
        ref logic               clk,
        ref logic               rst_n,
        // Write Interface
        ref logic               wr_en,
        ref logic [ADDR_W-1:0]  wr_addr,
        ref logic [DATA_W-1:0]  wr_data,
        // Read Interface
        ref logic [ADDR_W-1:0]  rd_addr_a,
        ref logic [ADDR_W-1:0]  rd_addr_b,
        ref logic [DATA_W-1:0]  rd_data_a,
        ref logic [DATA_W-1:0]  rd_data_b,
        ref logic               rd_valid_a,
        ref logic               rd_valid_b,
        // System Interface
        ref logic               uart_busy,
        ref logic [1:0]         uart_error,
        ref logic               update_ok,
        ref logic               uart_enable,
        ref logic [2:0]         uart_mode,
        ref logic [15:0]        uart_rate
    );
        case (testname)
            "tc_01_reset"      : test_reset_defaults (clk, rst_n, rd_data_a, rd_data_b, rd_valid_a, rd_valid_b, uart_enable, uart_mode, uart_rate);
            "tc_02_rw_basic"   : test_write_read     (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
            "tc_03_random_wr"  : test_random_write   (clk, wr_en, wr_addr, wr_data);
            "tc_04_random_rd"  : test_random_read    (clk, rd_addr_a, rd_addr_b);
            "tc_05_raw"        : test_raw            (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
            "tc_06_baud"       : test_baud_value     (clk, wr_en, update_ok, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
            // Note: test_oob tests both test_oob_write and test_oob_read
            "tc_07_oob"        : test_oob            (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_valid_a, rd_valid_b);
            "tc_08_sticky"     : test_sticky         (clk, wr_en, wr_addr, wr_data, uart_error);
            "tc_09_rd_busy"    : test_read_busy      (clk, uart_busy, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
            "tc_10_wr_busy"    : test_write_busy     (clk, wr_en, wr_addr, wr_data);
            "tc_all_tests"     : 
                begin
                    test_reset_defaults (clk, rst_n, rd_data_a, rd_data_b, rd_valid_a, rd_valid_b, uart_enable, uart_mode, uart_rate);
                    test_write_read     (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
                    test_random_write   (clk, wr_en, wr_addr, wr_data);
                    test_random_read    (clk, rd_addr_a, rd_addr_b);
                    test_raw            (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
                    test_baud_value     (clk, wr_en, update_ok, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
                    test_oob            (clk, wr_en, wr_addr, wr_data, rd_addr_a, rd_addr_b, rd_valid_a, rd_valid_b);
                    test_sticky         (clk, wr_en, wr_addr, wr_data, uart_error);
                    test_read_busy      (clk, uart_busy, rd_addr_a, rd_addr_b, rd_data_a, rd_data_b);
                    test_write_busy     (clk, wr_en, wr_addr, wr_data);
                end
            default :$display("You entered invalid test name, test name is %s",testname);
        endcase
    endtask


    // =================================================================================
    // Initialize task (For asserting all inputs with values at beginnig of simulation)
    // =================================================================================
    task automatic initialize(
        ref logic                 wr_en,
        ref logic [ADDR_W-1:0]    wr_addr,
        ref logic [ADDR_W-1:0]    rd_addr_a,
        ref logic [ADDR_W-1:0]    rd_addr_b,
        ref logic [DATA_W-1:0]    wr_data,
        ref logic                 uart_busy,
        ref logic [1:0]           uart_error,
        ref logic                 update_ok
    );
        wr_en      = 0;  wr_addr    = 0;
        rd_addr_a  = 0;  rd_addr_b  = 0;
        wr_data    = 0;  uart_busy  = 0;
        uart_error = 0;  update_ok  = 0;
    endtask

    // =========================================================
    // Primitive tasks (write_data / read_data / reset_assertion)
    // =========================================================

    task automatic reset_assertion(
        ref  logic clk,
        ref  logic rst_n
    );
        @(negedge clk);
        rst_n = 0;
        repeat(5) @(negedge clk);
        rst_n = 1;
        @(negedge clk);
    endtask

    task automatic write_data(
        ref   logic                 clk,
        ref   logic                 wr_en,
        ref   logic [ADDR_W-1:0]    r_wr_addr,
        ref   logic [DATA_W-1:0]    r_wr_data,
        input logic [ADDR_W-1:0]    t_wr_addr,
        input logic [DATA_W-1:0]    t_wr_data
    );
        r_wr_addr = t_wr_addr;
        r_wr_data = t_wr_data;
        wr_en     = 1;
        @(negedge clk);
        wr_en     = 0;
    endtask

    task automatic read_data(
        ref   logic                 clk,
        ref   logic [ADDR_W-1:0]    r_rd_addr_a,
        ref   logic [ADDR_W-1:0]    r_rd_addr_b,
        input logic [ADDR_W-1:0]    t_rd_addr,
        input bit                   a_or_b
    );
        if (a_or_b == PORTB)
            r_rd_addr_b = t_rd_addr;
        else
            r_rd_addr_a = t_rd_addr;

        if (READ_LATENCY==1)    
           @(negedge clk);  
        else
           #(CLK_PERIOD/4.0); 

    endtask

    // =========================================================
    // Test tasks
    // =========================================================

    // test_reset_defaults
    task automatic test_reset_defaults(
        ref        logic                            clk,
        ref        logic                            rst_n,
        const ref  logic   [DATA_W-1:0]             rd_data_a,
        const ref  logic   [DATA_W-1:0]             rd_data_b,
        const ref  logic                            rd_valid_a,
        const ref  logic                            rd_valid_b,
        const ref  logic                            uart_enable,
        const ref  logic   [2:0]                    uart_mode,
        const ref  logic   [15:0]                   uart_rate
        );

        fork
        reset_assertion(clk, rst_n);
        begin
        repeat(2)
        @(negedge clk);
        check_reset_defaults("test_reset_defaults",int'(rd_data_a),int'(0));
        check_reset_defaults("test_reset_defaults",int'(rd_data_b),int'(0));
        check_reset_defaults("test_reset_defaults",int'(rd_valid_a),int'(0));
        check_reset_defaults("test_reset_defaults",int'(rd_valid_b),int'(0));
        check_reset_defaults("test_reset_defaults",int'(uart_enable),int'(0));
        check_reset_defaults("test_reset_defaults",int'(uart_mode),int'(0));
        check_reset_defaults("test_reset_defaults",int'(uart_rate),int'(BAUD_RATE_DEFAULT_VALUE));
        end
    join
    endtask

    // test_write_read
    task automatic test_write_read(
        ref        logic                 clk,
        ref        logic                 wr_en,
        ref        logic [ADDR_W-1:0]    wr_addr,
        ref        logic [DATA_W-1:0]    wr_data,
        ref        logic [ADDR_W-1:0]    rd_addr_a,
        ref        logic [ADDR_W-1:0]    rd_addr_b,
        const ref  logic [DATA_W-1:0]    rd_data_a,
        const ref  logic [DATA_W-1:0]    rd_data_b
    );
        bit [15:0] data;
        
        read_data (clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTA);
        read_data (clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTB);
        
        data=$urandom_range(0,'hF);
        write_data(clk, wr_en, wr_addr, wr_data, ENABLE_AND_MODE_REG_ADDR, data);
        read_data (clk, rd_addr_a, rd_addr_b, ENABLE_AND_MODE_REG_ADDR, PORTA);
        read_data (clk, rd_addr_a, rd_addr_b, ENABLE_AND_MODE_REG_ADDR, PORTB);

        check_wr_rd("test_write_read",wr_data,rd_data_a,wr_addr,rd_addr_a,PORTA);
        check_wr_rd("test_write_read",wr_data,rd_data_b,wr_addr,rd_addr_b,PORTB);

    endtask

    // test_random_write
    task automatic test_random_write(
        ref logic                 clk,
        ref logic                 wr_en,
        ref logic [ADDR_W-1:0]    wr_addr,
        ref logic [DATA_W-1:0]    wr_data
    );
        repeat(15)
            write_data(clk, wr_en, wr_addr, wr_data, $urandom_range(2,0), $random);
        $display("Test name: [test_random_write] Depends on assertions");
    endtask

    // test_random_read
    task automatic test_random_read(
        ref logic                 clk,
        ref logic [ADDR_W-1:0]    rd_addr_a,
        ref logic [ADDR_W-1:0]    rd_addr_b
    );
        repeat(15)
            read_data(clk, rd_addr_a, rd_addr_b, $urandom_range(2,0), $random);
        $display("Test name: [test_random_read] Depends on assertions");
    endtask

    // test_raw
    task automatic test_raw(
        ref logic                         clk,
        ref logic                         wr_en,
        ref logic [ADDR_W-1:0]            wr_addr,
        ref logic [DATA_W-1:0]            wr_data,
        ref logic [ADDR_W-1:0]            rd_addr_a,
        ref logic [ADDR_W-1:0]            rd_addr_b,
        const ref  logic [DATA_W-1:0]     rd_data_a,
        const ref  logic [DATA_W-1:0]     rd_data_b
    );
        logic [ADDR_W-1:0] raw_addr;
        repeat(10) begin
            raw_addr = $random;
            fork
                write_data(clk, wr_en, wr_addr, wr_data, raw_addr, $random);
                read_data (clk, rd_addr_a, rd_addr_b, raw_addr, PORTA);
                read_data (clk, rd_addr_a, rd_addr_b, raw_addr, PORTB);
                begin 
                    @(negedge clk);
                    check_wr_rd("test_raw",wr_data,rd_data_a,raw_addr,raw_addr,PORTA);
                    check_wr_rd("test_raw",wr_data,rd_data_b,raw_addr,raw_addr,PORTB);
                end    
            join
        end
    endtask

    // test_baud_value
    task automatic test_baud_value(
        ref        logic                  clk,
        ref        logic                  wr_en,
        ref        logic                  update_ok,
        ref        logic [ADDR_W-1:0]     wr_addr,
        ref        logic [DATA_W-1:0]     wr_data,
        ref        logic [ADDR_W-1:0]     rd_addr_a,
        ref        logic [ADDR_W-1:0]     rd_addr_b,
        const ref  logic [DATA_W-1:0]     rd_data_a,
        const ref  logic [DATA_W-1:0]     rd_data_b
    );
        bit [15:0] baud_rate;

        repeat(5) begin
            baud_rate=$random;
            update_ok = 1;
            write_data(clk, wr_en, wr_addr, wr_data, BAUD_RATE_REG_ADDR, baud_rate);
            @(negedge clk);
            fork
                read_data(clk, rd_addr_a, rd_addr_b, BAUD_RATE_REG_ADDR, PORTA);
                read_data(clk, rd_addr_a, rd_addr_b, BAUD_RATE_REG_ADDR, PORTB);
            join
            check_baud_rate("test_baud_value",wr_data,rd_data_a);
            check_baud_rate("test_baud_value",wr_data,rd_data_b);
            update_ok = 0;
        end
    endtask

    // test_oob
    task automatic test_oob(
        ref        logic                 clk,
        ref        logic                 wr_en,
        ref        logic [ADDR_W-1:0]    wr_addr,
        ref        logic [DATA_W-1:0]    wr_data,
        ref        logic [ADDR_W-1:0]    rd_addr_a,
        ref        logic [ADDR_W-1:0]    rd_addr_b,
        const ref  logic                 rd_valid_a,
        const ref  logic                 rd_valid_b
    );
      
        // test read after write
        $display("Test name: [test_write_oob] Depends on assertions");
        repeat(3) begin
            write_data(clk, wr_en, wr_addr, wr_data, ILLEGAL_ADDR, $random);
            read_data (clk, rd_addr_a, rd_addr_b, ILLEGAL_ADDR, PORTA);
            check_rd_oob("test_read_oob",rd_valid_a,PORTA);
            read_data (clk, rd_addr_a, rd_addr_b, ILLEGAL_ADDR, PORTB);
            check_rd_oob("test_read_oob",rd_valid_b,PORTB);
            //read_data (clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTB);
        end

        // test write & read simultaneously
        fork
            write_data(clk, wr_en, wr_addr, wr_data, ILLEGAL_ADDR, $random);
            read_data (clk, rd_addr_a, rd_addr_b, ILLEGAL_ADDR, PORTA);
            read_data (clk, rd_addr_a, rd_addr_b, ILLEGAL_ADDR, PORTB);
            begin
                @(posedge clk)
                check_rd_oob("test_read_oob",rd_valid_a,PORTA);
                check_rd_oob("test_read_oob",rd_valid_b,PORTB);
            end    
        join

    endtask

    // test_sticky
    task automatic test_sticky(
        ref logic                 clk,
        ref logic                 wr_en,
        ref logic [ADDR_W-1:0]    wr_addr,
        ref logic [DATA_W-1:0]    wr_data,
        ref logic [1:0]           uart_error
    );

        $display("Test name: [test_sticky] Depends on assertions");
        fork
            begin
                repeat(15) begin uart_error = $random; @(negedge clk); end
                uart_error = 0;
            end
            repeat(20)
                write_data(clk, wr_en, wr_addr, wr_data, ERROR_AND_BUSY_BITS_REG_ADDR,{$urandom_range(1,0), 1'b0} & 16'h0002);
        join
    endtask

    // test_read_busy
    task automatic test_read_busy(
        ref        logic                 clk,
        ref        logic                 uart_busy,
        ref        logic [ADDR_W-1:0]    rd_addr_a,
        ref        logic [ADDR_W-1:0]    rd_addr_b,
        const ref  logic [DATA_W-1:0]    rd_data_a,
        const ref  logic [DATA_W-1:0]    rd_data_b
    );
        
        uart_busy = 1;
        @(negedge clk);
        read_data(clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTA);
        check_rd_busy("test_read_busy",rd_data_a[BUSY_BIT],uart_busy,PORTA);
        read_data(clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTB);
        check_rd_busy("test_read_busy",rd_data_b[BUSY_BIT],uart_busy,PORTB);
        
        uart_busy = 0;
        @(negedge clk);
        read_data(clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTA);
        check_rd_busy("test_read_busy",rd_data_a[BUSY_BIT],uart_busy,PORTA);
        read_data(clk, rd_addr_a, rd_addr_b, ERROR_AND_BUSY_BITS_REG_ADDR, PORTB);
        check_rd_busy("test_read_busy",rd_data_b[BUSY_BIT],uart_busy,PORTB);
    endtask

    // test_write_busy
    task automatic test_write_busy(
        ref logic                 clk,
        ref logic                 wr_en,
        ref logic [ADDR_W-1:0]    wr_addr,
        ref logic [DATA_W-1:0]    wr_data
    );

        $display("Test name: [test_write_busy] Depends on assertions");
        
        repeat(5)
            write_data(clk, wr_en, wr_addr, wr_data, ERROR_AND_BUSY_BITS_REG_ADDR, $urandom_range(1,0));

    endtask

    // =========================================================
    // Checker tasks
    // =========================================================

    task automatic check_reset_defaults(string test_name,int dut_value,int golden_value);
        if(dut_value==golden_value)
            $display("Test name: [%s] PASS",test_name);

        else
            $display("Test name: [%s] FAIL",test_name);
    endtask

    task automatic check_wr_rd(string test_name,bit [DATA_W-1:0] wr_data, rd_data, bit [ADDR_W-1:0] wr_addr,rd_addr,bit PORT);
        string PORT_str;
        PORT_str=(PORT)? "PORTB":"PORTA";
        if(wr_data==rd_data)
            $display("Test name: [%s] PASS,   READ PORT: %0s wr_addr = %0h, rd_addr = %0h, wr_data = 0x%0h, rd_data = 0x%0h,",test_name,PORT_str,
            wr_addr,rd_addr,wr_data,rd_data);

        else
            $display("Test name: [%s] FAIL,   READ PORT: %0s wr_addr = %0h, rd_addr = %0h, wr_data = 0x%0h, rd_data = 0x%0h,",test_name,PORT_str,
            wr_addr,rd_addr,wr_data,rd_data);
    endtask

    task automatic check_baud_rate(string test_name,bit [DATA_W-1:0] baud_wr_value,baud_rd_value);
        if(baud_wr_value==baud_rd_value)
            $display("Test name: [%s] PASS,   Baud Write value = %0d, Baud Read value = %0d",test_name,baud_wr_value,baud_rd_value);

        else
            $display("Test name: [%s] FAIL,   Baud Write value = %0d, Baud Read value = %0d",test_name,baud_wr_value,baud_rd_value);
    endtask

    task automatic check_rd_oob(string test_name,bit rd_valid,PORT);
        string PORT_str;
        PORT_str=(PORT)? "PORTB":"PORTA";
        if(!rd_valid)
            $display("Test name: [%s] PASS,   READ PORT: %0s, Read Valid = %0d",test_name,PORT_str,rd_valid);

        else
            $display("Test name: [%s] FAIL,   READ PORT: %0s, Read Valid = %0d",test_name,PORT_str,rd_valid);
    endtask

    task automatic check_rd_busy(string test_name,bit rd_data_busy,bit uart_busy,PORT);
        string PORT_str;
        PORT_str=(PORT)? "PORTB":"PORTA";
        if(rd_data_busy==uart_busy)
            $display("Test name: [%s] PASS,   READ PORT: %0s, read data of busy register = %0b, uart busy = %0b",test_name,PORT_str,rd_data_busy,uart_busy);

        else
            $display("Test name: [%s] FAIL,   READ PORT: %0s, read data of busy register = %0b, uart busy = %0b",test_name,PORT_str,rd_data_busy,uart_busy);
    endtask

endpackage