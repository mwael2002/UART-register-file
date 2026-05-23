package common_pkg_uart_regfile;

    parameter DATA_W=16, N_REGS=3;
    parameter CLK_PERIOD=2;

    `ifdef READ_LATENCY_VAL
        parameter READ_LATENCY = `READ_LATENCY_VAL;
    `else
        parameter bit READ_LATENCY=0; 
    `endif


    
endpackage
