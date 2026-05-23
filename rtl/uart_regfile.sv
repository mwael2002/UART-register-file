module uart_regfile
#(parameter DATA_W=16,N_REGS=3,parameter bit READ_LATENCY=1)(
// Clock/Reset
input  logic                             clk,
input  logic                             rst_n,

// Host Interface
input  logic                            wr_en,
input  logic   [$clog2(N_REGS)-1:0]     wr_addr,
input  logic   [DATA_W-1:0]             wr_data,
input  logic   [$clog2(N_REGS)-1:0]     rd_addr_a,
input  logic   [$clog2(N_REGS)-1:0]     rd_addr_b,
output logic   [DATA_W-1:0]             rd_data_a,
output logic   [DATA_W-1:0]             rd_data_b,
output logic                            rd_valid_a,
output logic                            rd_valid_b,

// System Interface
input  logic                            uart_busy,
input  logic   [1:0]                    uart_error,
input  logic                            update_ok, 
output logic                            uart_enable,
output logic   [2:0]                    uart_mode,
output logic   [15:0]                   uart_rate
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

logic [DATA_W-1:0] mem [0:N_REGS-1];            // Register file
logic [DATA_W-1:0] rd_data_a_tmp,rd_data_b_tmp;     // localvariables store read data
logic [BAUD_RATE_MSB:BAUD_RATE_LSB] shadow_reg;     // Shadow Register
bit   [$clog2(N_REGS)-1:0] i;


// Output assignments
assign uart_enable=mem[ENABLE_AND_MODE_REG_ADDR][ENABLE_BIT];
assign uart_mode=mem[ENABLE_AND_MODE_REG_ADDR][MODE_MSB:MODE_LSB];
assign uart_rate=mem[BAUD_RATE_REG_ADDR][BAUD_RATE_MSB:BAUD_RATE_LSB];

// Shadow register for copying baud rate value before writing it to active register
always_ff @(posedge clk) begin
    if(!rst_n)
        shadow_reg<=BAUD_RATE_DEFAULT_VALUE;
    
    else if(wr_en && wr_addr==BAUD_RATE_REG_ADDR)
        shadow_reg<=wr_data[BAUD_RATE_MSB:BAUD_RATE_LSB];    
end


// Write Operation
always_ff @(posedge clk) begin

    if (!rst_n) begin

        for(i=0;i<=MAXIMUM_ADDR;i++) begin 
                if(i==BAUD_RATE_REG_ADDR) begin
                    mem[BAUD_RATE_REG_ADDR] <= BAUD_RATE_DEFAULT_VALUE;
                end    
                else
                mem[i] <= 'b0;
        end
    end
    else begin
        mem[ERROR_AND_BUSY_BITS_REG_ADDR][BUSY_BIT]<=uart_busy;
        mem[BAUD_RATE_REG_ADDR][BAUD_RATE_MSB:BAUD_RATE_LSB]<=(update_ok)?shadow_reg:mem[BAUD_RATE_REG_ADDR][BAUD_RATE_MSB:BAUD_RATE_LSB];

        if(|uart_error) // Hardware Priority to write over software
                mem[ERROR_AND_BUSY_BITS_REG_ADDR][ERROR_BIT]<=1;       
        
        else if(wr_addr==ERROR_AND_BUSY_BITS_REG_ADDR && wr_en && wr_data[ERROR_BIT])
                mem[wr_addr][ERROR_BIT]<=0;  

        if (wr_en && wr_addr == ENABLE_AND_MODE_REG_ADDR) begin
                mem[wr_addr][MODE_MSB:MODE_LSB]<=wr_data[MODE_MSB:MODE_LSB];
                mem[wr_addr][ENABLE_BIT]<=wr_data[ENABLE_BIT];
        end
    end
end


// Read Operation
always_comb begin
    rd_data_a_tmp = (rd_addr_a>MAXIMUM_ADDR)?0:mem[rd_addr_a];
    rd_data_b_tmp = (rd_addr_b>MAXIMUM_ADDR)?0:mem[rd_addr_b];
end

// Generate combinational or sequential logic based on READ_LATENCY value
generate
    if (READ_LATENCY == 0) begin 
        assign rd_data_a  = (rd_addr_a==wr_addr && wr_en)?wr_data:rd_data_a_tmp;
        assign rd_data_b  = (rd_addr_b==wr_addr && wr_en)?wr_data:rd_data_b_tmp;
        assign rd_valid_a = (rd_addr_a>MAXIMUM_ADDR || !rst_n)?0:1;
        assign rd_valid_b = (rd_addr_b>MAXIMUM_ADDR || !rst_n)?0:1;
    end 
    else begin 
   
        always_ff @(posedge clk) begin
            if (!rst_n) begin
                rd_valid_a<=0;
                rd_valid_b<=0;
            end 
            else begin
                if(rd_addr_a>MAXIMUM_ADDR) begin
                    rd_valid_a<=0;
                end

                else begin
                    rd_valid_a<=1;
                end

                if(rd_addr_b>MAXIMUM_ADDR) begin
                    rd_valid_b<=0;
                end

                else begin
                    rd_valid_b<=1;
                end
            end
        end

        always_ff @(posedge clk) begin
            if (!rst_n) begin
                rd_data_a<=0;
                rd_data_b<=0;
            end
            else begin
                rd_data_a<=(rd_addr_a==wr_addr && wr_en)?wr_data:rd_data_a_tmp;
                rd_data_b<=(rd_addr_b==wr_addr && wr_en)?wr_data:rd_data_b_tmp;
            end
        end
    end
endgenerate


endmodule