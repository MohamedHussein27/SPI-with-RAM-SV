interface ram_if(clk);
    input clk;

    parameter MEM_DEPTH = 256;
    parameter ADDR_SIZE = 8;

    // signals
    logic rst_n;
    logic rx_valid;
    logic [9:0] din;
    logic [7:0] dout;
    logic tx_valid;

    // design module
    modport DUT (
        input clk, rst_n, rx_valid, din,
        output dout, tx_valid
    );
    // test module
    modport TEST (
        output rst_n, rx_valid, din,
        input clk, dout, tx_valid
    );
    // monitor module
    modport MONITOR (
        input clk, rst_n, rx_valid, din, dout, tx_valid
    );
endinterface