import ram_transaction_pkg::*;
import shared_pkg::*;
module ram_tb (ram_if.TEST ramif);
    logic clk;
    logic rst_n;
    logic rx_valid;
    logic [9:0] din;
    logic [7:0] dout;
    logic tx_valid;
    // assigning signals to be interfaced
    // inputs
    assign clk = ramif.clk;
    assign dout = ramif.dout;
    assign tx_valid = ramif.tx_valid;
    // outputs
    assign ramif.rst_n = rst_n;
    assign ramif.rx_valid = rx_valid;
    assign ramif.din = din;

    // class object
    RAM_transaction tr_tb = new;

    // stimulus
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
        repeat(1000) begin
            assert(tr_tb.randomize());
            //tr_tb.equal_address.constraint_mode(0); // cancel the equal address constraint half of the test
            // getting randomized stimulus
            rst_n = tr_tb.rst_n;
            rx_valid = tr_tb.rx_valid;
            din = tr_tb.din;
            #20;
        end
        /*repeat(500) begin
            assert(tr_tb.randomize());
            //tr_tb.equal_address.constraint_mode(1); // enforce equal address constraint
            // getting randomized stimulus
            rst_n = tr_tb.rst_n;
            rx_valid = tr_tb.rx_valid;
            din = tr_tb.din;
            #20;
        end*/
        test_finished = 1; // end of test
    end
endmodule