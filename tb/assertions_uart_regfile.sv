module asser_uart_regfile

#(parameter DATA_W=16,N_REGS=3,READ_LATENCY=0)(
// Clock/Reset
input  logic                             clk,
input  logic                             rst_n,

// Host Interface
input  logic                            wr_en,
input  logic   [$clog2(N_REGS)-1:0]     wr_addr,
input  logic   [DATA_W-1:0]             wr_data,
input  logic   [$clog2(N_REGS)-1:0]     rd_addr_a,
input  logic   [$clog2(N_REGS)-1:0]     rd_addr_b,
input  logic   [DATA_W-1:0]             rd_data_a,  // output
input  logic   [DATA_W-1:0]             rd_data_b,  // output
input  logic                            rd_valid_a, // output
input  logic                            rd_valid_b, // output
 
// System Interface
input  logic                            uart_busy,
input  logic   [1:0]                    uart_error,
input  logic                            update_ok, 
input  logic                            uart_enable, // output
input  logic   [2:0]                    uart_mode,   // output
input  logic   [15:0]                   uart_rate,    // output

// Shadow register
input  logic [15:0] shadow_reg,

// Reg file
input  var logic [DATA_W-1:0] mem [N_REGS]

);

  // local parameter for the maximum address that can be written to/read from
  localparam MAXIMUM_ADDR=N_REGS-1;

  // local parameters for constant register addresses 
  localparam ERROR_AND_BUSY_BITS_REG_ADDR=2;
  localparam ENABLE_AND_MODE_REG_ADDR=0;
  localparam BAUD_RATE_REG_ADDR=1;

  // local parameter for bit fields
  localparam ERROR_BIT=1;
  localparam BUSY_BIT=0;
  localparam ENABLE_BIT=0;
  localparam BAUD_RATE_MSB=15;
  localparam BAUD_RATE_LSB=0;
  localparam MODE_MSB=3;
  localparam MODE_LSB=1;

  // localparam for default baudrate = 9600 bps
  localparam BAUD_RATE_DEFAULT_VALUE=9600;



  //A1 checks reset values of register file & Shadow register
  A11:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (mem[ENABLE_AND_MODE_REG_ADDR]=='b0)));
  A12:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (mem[BAUD_RATE_REG_ADDR]==BAUD_RATE_DEFAULT_VALUE)));
  A13:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (mem[ERROR_AND_BUSY_BITS_REG_ADDR]=='b0)));
  A14:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (shadow_reg==BAUD_RATE_DEFAULT_VALUE)));

  // A2 Check all outputs are not x  
  A21:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (|rd_data_a!==1'bx)));
  A23:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (|rd_data_b!==1'bx)));
  A24:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (rd_valid_a!==1'bx)));
  A25:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (rd_valid_b!==1'bx)));
  A26:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (uart_enable!==1'bx)));
  A27:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (uart_mode!==1'bx)));
  A28:assert property(disable iff(rst_n) (@(posedge clk) (!rst_n) |=> (|uart_rate!==1'bx)));

  // A3 Software checks reserved bits
  property p31;
    disable iff(!rst_n) @(posedge clk) (wr_addr==ENABLE_AND_MODE_REG_ADDR && wr_en && wr_data[DATA_W-1:MODE_MSB+1]!=mem[ENABLE_AND_MODE_REG_ADDR][DATA_W-1:MODE_MSB+1]) |=> $stable(mem[ENABLE_AND_MODE_REG_ADDR][DATA_W-1:MODE_MSB+1]) ;
  endproperty
  
  A31: assert property(p31); 

  property p32;
    disable iff(!rst_n) @(posedge clk) (wr_addr==ERROR_AND_BUSY_BITS_REG_ADDR && wr_en && wr_data[DATA_W-1:ERROR_BIT+1]!=mem[ERROR_BIT+1][DATA_W-1:ERROR_BIT+1]) |=> $stable(mem[ERROR_AND_BUSY_BITS_REG_ADDR][DATA_W-1:ERROR_BIT+1]) ;
  endproperty
  
  A32: assert property(p32); 

  //A4 Write & Read from same address at same cycle
generate;
    
  if(READ_LATENCY==1) begin :A4_READ_LATENCY_1
    property p41;
      disable iff(!rst_n) @(posedge clk) (wr_addr == rd_addr_a && wr_en && wr_addr<N_REGS) |=> (rd_data_a == $past(wr_data));
    endproperty

    A41: assert property (p41);

    property p42;
      disable iff(!rst_n) @(posedge clk) (wr_addr == rd_addr_b && wr_en && wr_addr<N_REGS) |=> (rd_data_b ==  $past(wr_data));
    endproperty

    A42: assert property (p42);
  end

  else begin :A4_READ_LATENCY_0
    property p41;
      disable iff(!rst_n) @(posedge clk) (wr_addr == rd_addr_a && wr_en && wr_addr<N_REGS) |-> (rd_data_a == wr_data);
    endproperty

    A41: assert property (p41);

    property p42;
      disable iff(!rst_n) @(posedge clk) (wr_addr == rd_addr_b && wr_en && wr_addr<N_REGS) |-> (rd_data_b == wr_data);
    endproperty

    A42: assert property (p42);
  end  
endgenerate

  // A5 Clear Sticky bit  
  property p5;
    disable iff(!rst_n) @(posedge clk) (|uart_error) |=> (mem[ERROR_AND_BUSY_BITS_REG_ADDR][ERROR_BIT]) ##0 (wr_addr==ERROR_AND_BUSY_BITS_REG_ADDR && wr_en && wr_data[ERROR_BIT]==1 && !uart_error) [->1] ##1 !mem[ERROR_AND_BUSY_BITS_REG_ADDR][ERROR_BIT];
  endproperty

  A5: assert property(p5);
  
  // A6 Try to clear error while uart_error is asserted
  property p6;
    disable iff(!rst_n) @(posedge clk) (|uart_error && wr_addr==ERROR_AND_BUSY_BITS_REG_ADDR && wr_en && wr_data[ERROR_BIT]==1) |=>  mem[ERROR_AND_BUSY_BITS_REG_ADDR][ERROR_BIT];
  endproperty

  A6: assert property(p6);

  // A7 BAUD Rate update
  property p7;
    disable iff(!rst_n) @(posedge clk) (wr_addr==BAUD_RATE_REG_ADDR && wr_en)  |=> (shadow_reg==$past(wr_data)) ##0 (update_ok && wr_addr==BAUD_RATE_REG_ADDR) [->1]  ##1 (mem[BAUD_RATE_REG_ADDR]==$past(shadow_reg));
  endproperty

  A7: assert property(p7);
  
  // A8 OOB Write  
  property p81;
    disable iff(!rst_n) @(posedge clk) (wr_en && wr_addr>=N_REGS)  |=> (mem[ENABLE_AND_MODE_REG_ADDR]==$past(mem[ENABLE_AND_MODE_REG_ADDR])) ;
  endproperty

  A81: assert property(p81);

  property p82;
    disable iff(!rst_n) @(posedge clk) (wr_en && wr_addr>=N_REGS && !update_ok)  |=> (mem[BAUD_RATE_REG_ADDR]==$past(mem[BAUD_RATE_REG_ADDR])) ;
  endproperty
  
  A82: assert property(p82);

  property p83;
    disable iff(!rst_n) @(posedge clk) (wr_en && wr_addr>=N_REGS && $stable(uart_error) && $stable(uart_busy))  |=> (mem[ERROR_AND_BUSY_BITS_REG_ADDR]==$past(mem[ERROR_AND_BUSY_BITS_REG_ADDR])) ;
  endproperty
  
  A83: assert property(p83);
  
  // A9 OOB Read
  generate
    if (READ_LATENCY==1) begin :A9_READ_LATENCY_1
    property p91;
      disable iff(!rst_n) @(posedge clk) (rd_addr_a>=N_REGS)  |=> (!rd_valid_a) ;
    endproperty

    A91: assert property(p91);

    property p92;
      disable iff(!rst_n) @(posedge clk) (rd_addr_b>=N_REGS)  |=> (!rd_valid_b) ;
    endproperty
    
    A92: assert property(p92);
  end

  else begin :A9_READ_LATENCY_0
    property p91;
      disable iff(!rst_n) @(posedge clk) (rd_addr_a>=N_REGS)  |-> (!rd_valid_a) ;
    endproperty

    A91: assert property(p91);

    property p92;
      disable iff(!rst_n) @(posedge clk) (rd_addr_b>=N_REGS)  |-> (!rd_valid_b) ;
    endproperty
    
    A92: assert property(p92);
  end  
  endgenerate

  // A10 Software writes busy bit
  property p10;
    disable iff(!rst_n) @(posedge clk) (wr_addr==ERROR_AND_BUSY_BITS_REG_ADDR && wr_en && wr_data[BUSY_BIT]!=mem[ERROR_AND_BUSY_BITS_REG_ADDR][BUSY_BIT] )  |=> $stable(uart_busy) ;
  endproperty
  
  A10: assert property(p10); 



endmodule
