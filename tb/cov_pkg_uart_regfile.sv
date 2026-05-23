package cov_pkg_uart_regfile;

    
    class uart_regfile_class  #(parameter DATA_W=16,N_REGS=3);
        
        localparam ADDR_W=$clog2(N_REGS);

        logic                   rst_n,uart_busy,uart_rate,wr_en;
        logic   [1:0]           uart_error;
        logic   [ADDR_W-1:0]    wr_addr,rd_addr_a,rd_addr_b;
        logic   [DATA_W-1:0]    wr_data,rd_data_a,rd_data_b;

        covergroup cvr_gp;

        cp_rst_n: coverpoint rst_n;
        cp_uart_error: coverpoint uart_error;
        cp_uart_busy: coverpoint uart_busy;
        
        // wr_en cp
        cp_wr_en: coverpoint wr_en{
          bins wr_en_0={0};
          bins wr_en_1={1};  
        }

        // Write address cp when only wr_en is asserted
        cp_wr_addr: coverpoint wr_addr iff(wr_en && rst_n){
            bins wr_legal []={[0:N_REGS-1]};
            illegal_bins wr_oob []={[N_REGS:(2**ADDR_W)-1]};
        }
        
        // Read address A cp
        cp_rd_addr_a: coverpoint rd_addr_a iff(rst_n){
            bins rd_a_legal []={[0:N_REGS-1]};
            illegal_bins rd_a_oob []={[N_REGS:(2**ADDR_W)-1]};
        }

        // Read Address B cp
        cp_rd_addr_b: coverpoint rd_addr_b iff(rst_n){
            bins rd_b_legal []={[0:N_REGS-1]};
            illegal_bins rd_b_oob []={[N_REGS:(2**ADDR_W)-1]};
        }


       // RAW PORTA
       cp_RAW_A: cross cp_wr_addr,cp_wr_en iff(wr_addr==rd_addr_a){
            ignore_bins wr_op_ign= binsof(cp_wr_en) intersect {0};
        }

       // RAW PORTB
       cp_RAW_B: cross cp_wr_addr,cp_wr_en iff(wr_addr==rd_addr_b){
            ignore_bins wr_op_ign= binsof(cp_wr_en) intersect {0};
       }

        endgroup

        function new();

            cvr_gp=new();
            
        endfunction

    endclass 
    
endpackage