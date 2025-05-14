import spi_slave_transaction_pkg::*;
import spi_slave_shared_pkg::*;
module spi_slave_tb (spi_slave_if.TEST spi_slaveif);
    logic clk;
    logic rst_n;
    logic MOSI;
    logic tx_valid;
    logic ss_n;
    logic [7:0] tx_data;
    logic MISO;
    logic rx_valid;
    logic [9:0] rx_data;
    // assigning signals to be interfaced
    // inputs
    assign clk = spi_slaveif.clk;
    assign MISO = spi_slaveif.MISO;
    assign rx_valid = spi_slaveif.rx_valid;
    assign rx_data  = spi_slaveif.rx_data;
    // outputs
    assign spi_slaveif.rst_n = rst_n;
    assign spi_slaveif.MOSI = MOSI;
    assign spi_slaveif.ss_n = ss_n;
    assign spi_slaveif.tx_valid = tx_valid;
    assign spi_slaveif.tx_data  = tx_data;

    // class object
    SPI_SLAVE_transaction tr_tb = new;

    // stimulus
    initial begin
        rst_n = 0;
        #20;
        rst_n = 1;
        repeat(1000) begin
            fork
                // process 1 (randomization)
                begin
                    assert(tr_tb.randomize());
                    // getting randomized stimulus
                    rst_n = tr_tb.rst_n;
                    MOSI = tr_tb.MOSI;
                    sampling_MOSI = tr_tb.MOSI; // used in constrianting MOSI (defined in shared package)
                    ss_n = tr_tb.ss_n;
                    tx_valid = tr_tb.tx_valid;
                    tx_data  = tr_tb.tx_data;
                    #20;
                end
                // process 2 (MOSI constriants timing)
                begin
                    if(ns == WRITE) begin // made it for one clock as to be write_add or write_data randomly
                        #20;
                        tr_tb.MOSI_write_con.constraint_mode(0); // Disable the constraint after 1 cycles
                    end
                end
                begin
                    if(ns == READ_ADD) begin // made it for two clocks to make the first two values of MOSI to be 2'b10 in case of read_add state 
                        #20;
                        if (constraint_done) tr_tb.MOSI_read_add_con.constraint_mode(0); // Disable the constraint after 1 cycles
                        constraint_done = 1; // defined in shared package
                        i++; // defined in shared package
                    end
                end
                begin
                    if(ns == READ_DATA) begin // made it for two clocks to make the first two values of MOSI to be 2'b11 in case of read_data state
                        #20;
                        if (constraint_done) tr_tb.MOSI_read_data_con.constraint_mode(0); // Disable the constraint after 1 cycles
                        constraint_done = 1; // defined in shared package
                    end
                end
                // process 3
                begin
                    if(cs == IDLE) begin
                        // enable all the constraints
                        tr_tb.MOSI_write_con.constraint_mode(1); 
                        tr_tb.MOSI_read_add_con.constraint_mode(1);
                        tr_tb.MOSI_read_data_con.constraint_mode(1);
                        constraint_done = 0; // defined in shared package
                        i = 0; // defined in shared package
                    end
                end
            join
        end
        test_finished = 1; // end of test
    end
endmodule