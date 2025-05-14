module spi_wrapper_top();
    bit clk;

    // clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // interface
    spi_wrapper_if spi_wrapperif (clk);
    // dut
    SPI_Wrapper dut (spi_wrapperif);
    // test
    spi_wrapper_tb tb (spi_wrapperif);
    // monitor
    spi_wrapper_monitor MONITOR (spi_wrapperif);
endmodule