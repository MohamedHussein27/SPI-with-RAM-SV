//this module is to connect between the SPI_SLAVE and RAM modules
module SPI_Wrapper (spi_wrapper_if.DUT spi_wrapperif);
    parameter MEM_DEPTH = 256 ;
    parameter ADDR_SIZE = 8;
    logic clk;
    logic rst_n;
    logic MOSI;
    logic ss_n;
    logic MISO;
    // assigning signals to be interfaced
    // inputs
    assign clk = spi_wrapperif.clk;
    assign rst_n = spi_wrapperif.rst_n;
    assign MOSI = spi_wrapperif.MOSI;
    assign ss_n = spi_wrapperif.ss_n;
    // outputs
    assign spi_wrapperif.MISO = MISO;

    // internals
    wire [9:0] rxdata ;
    wire [7:0] txdata ;
    wire rx_valid , tx_valid ;

    SPI_SLAVE SPI(
        .MOSI(MOSI),
        .MISO(MISO),
        .clk(clk),
        .ss_n(ss_n),
        .rst_n(rst_n),
        .rx_data(rxdata),
        .tx_data(txdata),
        .rx_valid(rx_valid),
        .tx_valid(tx_valid)
    );

    RAM #(MEM_DEPTH,ADDR_SIZE) Ram (
        .din(rxdata),
        .dout(txdata),
        .clk(clk),
        .rx_valid(rx_valid),
        .tx_valid(tx_valid),
        .rst_n(rst_n)
    );
endmodule