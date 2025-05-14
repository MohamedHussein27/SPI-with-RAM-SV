module RAM (ram_if.DUT ramif);
    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;
    logic clk;
    logic rst_n;
    logic rx_valid;
    logic [9:0] din;
    logic [7:0] dout;
    logic tx_valid;

    // assigning signals to be interfaced
    // inputs
    assign clk = ramif.clk;
    assign rst_n = ramif.rst_n;
    assign rx_valid = ramif.rx_valid;
    assign din = ramif.din;
    // outputs
    assign ramif.dout = dout;
    assign ramif.tx_valid = tx_valid;

    // Creating the memory array
    reg [ADDR_SIZE-1:0] memory [MEM_DEPTH-1:0]; //address size is the same as memory width

    reg [7:0] addr_wr; // Write address for writing data
    reg [7:0] addr_re; // Read address for reading data 

    // assertions
    // immediate signals
    /*always_comb begin
        if(!rst_n) begin
            `ifdef SIM // to make it invisible when synthesizing
                dout_ia: assert final(dout == 8'h00);
                tx_valid_ia: assert final(tx_valid == 1'b0);
                addr_wr_ia:  assert final(addr_wr  == 8'h00);
                addr_re_ia:  assert final(addr_re  == 8'h00);
            `endif
        end
    end*/
    
    // properties
    property rst_n_p; // check the value of the outputs, read address and write address when reset
        @(posedge clk) (!rst_n) |=> ((dout == 8'h00) && (tx_valid == 1'b0) && (addr_wr == 8'h00) && (addr_re == 8'h00));
    endproperty

    property addr_wr_p; // check on write address when operation is write address
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] == 2'b00) |=> (addr_wr == $past(din[7:0]));
    endproperty

    property addr_re_p; // check on read address when operation is read address
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] == 2'b10) |=> (addr_re == $past(din[7:0]));
    endproperty

    property w_data_p; // check on memory value when write data
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] == 2'b01) |=> (memory[addr_wr] == $past(din[7:0]));
    endproperty

    property r_data_p; // check on dout when operatoion is read data
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] == 2'b11) |=> (dout === $past(memory[$past(addr_re)]));
    endproperty

    property tx_valid_p; // check on tx_valid when the operation is read data
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] == 2'b11) |=> (tx_valid);
    endproperty

    property not_tx_valid_p; // check on tx_valid when the operation is not read data
        @(posedge clk) disable iff (rst_n == 0) rx_valid && (din[9:8] != 2'b11) |=> (!tx_valid);
    endproperty

    property not_rx_valid_p; // check on the value of dout when rx_valid is not high
        @(posedge clk) disable iff (rst_n == 0) (!rx_valid) && (din[9:8] == 2'b11) |=> (dout === $past(dout));
    endproperty

    // garded assertions
    `ifdef SIM
        rst_n_a: assert property (rst_n_P); 
        addr_wr_a: assert property (addr_wr_p);
        addr_re_a: assert property (addr_re_p);
        w_data_a:  assert property (w_data_p);
        r_data_a:  assert property (r_data_p);
        tx_valid_a: assert property (tx_valid_p);
        not_tx_valid_a: assert property (not_tx_valid_p);
        not_rx_valid_a: assert property (not_rx_valid_p);
    `endif 
    // cover assertions
    rst_n_c: cover property (rst_n_p);
    addr_wr_c: cover property (addr_wr_p);
    addr_re_c: cover property (addr_re_p);
    w_data_c:  cover property (w_data_p );
    r_data_c:  cover property (r_data_p );
    tx_valid_c: cover property (tx_valid_p);
    not_tx_valid_c: cover property (not_tx_valid_p);
    not_rx_valid_c: cover property (not_rx_valid_p);
    


    always @(posedge clk) begin  
        if (!rst_n) begin   //making the reset synchronous so the memory is synthesized as a block
            dout <= 8'h00;
            tx_valid <= 1'b0;
            addr_wr <= 8'h00;
            addr_re <= 8'h00;
        end else begin
            if (rx_valid) begin // Once rx_valid is high, then the din bus is completed
                case (din[9:8])
                    2'b00: begin
                        addr_wr <= din[7:0]; // Write address
                        tx_valid <= 1'b0;
                    end
                    2'b01: begin
                        memory[addr_wr] <= din[7:0]; // Write data in the address specified earlier
                        tx_valid <= 1'b0;
                    end
                    2'b10: begin
                        addr_re <= din[7:0]; // Read address
                        tx_valid <= 1'b0;
                    end
                    2'b11: begin // Read data in the address specified earlier and then send the data in dout and make tx_valid high
                        dout <= memory[addr_re];
                        tx_valid <= 1'b1;
                    end
                endcase
            end
        end
    end
endmodule