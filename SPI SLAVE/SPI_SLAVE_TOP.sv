module spi_slave_top();
    bit clk;

    // clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // interface
    spi_slave_if spi_slaveif (clk);
    // dut
    SPI_SLAVE dut (spi_slaveif);
    // test
    spi_slave_tb tb (spi_slaveif);
    // monitor
    spi_slave_monitor MONITOR (spi_slaveif);
endmodule