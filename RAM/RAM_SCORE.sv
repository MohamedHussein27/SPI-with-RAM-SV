package ram_scoreboard_pkg;
    import ram_transaction_pkg::*;
    import shared_pkg::*;
    class RAM_scoreboard;
        parameter MEM_DEPTH = 256;
        parameter ADDR_SIZE = 8;
        // internal signals
        logic [ADDR_SIZE-1:0] ref_mem [MEM_DEPTH]; // fixed array to verify RAM 
        bit [7:0] r_addr, w_addr;
        
        // reference signals
        logic [7:0] dout_ref;
        logic tx_valid_ref;

        // compare function
        function void check_data (RAM_transaction tr);
            reference_model(tr);
            // compare
            if (tr.dout !== dout_ref) begin
                error_count_out++;
                $display("error in data out at %0d", error_count_out);
            end
            else
                correct_count_out++;
            if(tr.tx_valid !== tx_valid_ref) begin
                error_count_tx_valid++;
                $display("error in tx_valid at %0d", error_count_tx_valid);
            end
            else
                correct_count_tx_valid++;
        endfunction
        // reference function
        function void reference_model (RAM_transaction tr_ref);
            if(!tr_ref.rst_n) begin
                dout_ref = 8'h00;
                tx_valid_ref = 1'b0;
                r_addr = 8'h00;
                w_addr = 8'h00;
                wr_addr_done = 1'b0;
                rd_addr_done = 1'b0;
            end
            else begin
                if (tr_ref.rx_valid) begin
                    if (tr_ref.din[9:8] == 2'b00) begin // write address
                        w_addr = tr_ref.din[7:0];
                        wr_addr_done = 1'b1;
                        tx_valid_ref = 1'b0;
                    end
                    else if (tr_ref.din[9:8] == 2'b01) begin // write data
                        ref_mem[w_addr] = tr_ref.din[7:0];
                        tx_valid_ref = 1'b0;
                    end
                    else if (tr_ref.din[9:8] == 2'b10) begin // read address
                        r_addr = tr_ref.din[7:0];
                        rd_addr_done = 1'b1;
                        tx_valid_ref = 1'b0;
                    end
                    else if (tr_ref.din[9:8] == 2'b11) begin // read data
                        dout_ref = ref_mem[r_addr];
                        tx_valid_ref = 1'b1;
                    end
                end
            end
        endfunction
    endclass
endpackage