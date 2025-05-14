interface spi_slave_if(clk);
    input clk;

    // signals
    // inputs
    logic rst_n;
    logic MOSI;
    logic tx_valid;
    logic ss_n;
    logic [7:0] tx_data;
    // outputs
    logic MISO;
    logic rx_valid;
    logic [9:0] rx_data;

    // design module
    modport DUT (
        input clk, rst_n, MOSI, tx_valid, ss_n, tx_data,
        output MISO, rx_valid, rx_data
    );
    // test module
    modport TEST (
        output rst_n, MOSI, tx_valid, ss_n, tx_data,
        input clk,  MISO, rx_valid, rx_data
    );
    // monitor module
    modport MONITOR (
        input clk, rst_n, MOSI, tx_valid, ss_n, tx_data, MISO, rx_valid, rx_data
    );
endinterface