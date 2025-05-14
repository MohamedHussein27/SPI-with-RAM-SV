import spi_wrapper_transaction_pkg::*;
import spi_wrapper_shared_pkg::*;
module spi_wrapper_tb (spi_wrapper_if.TEST spi_wrapperif);
    logic clk;
    logic rst_n;
    logic MOSI;
    logic ss_n;
    logic MISO;
    logic [7:0] test0, test1, test2, test3, test4;
    // assigning signals to be interfaced
    // inputs
    assign clk = spi_wrapperif.clk;
    assign MISO = spi_wrapperif.MISO;
    // outputs
    assign spi_wrapperif.rst_n = rst_n;
    assign spi_wrapperif.MOSI = MOSI;
    assign spi_wrapperif.ss_n = ss_n;

    // class object
    SPI_WRAPPER_transaction tr_tb = new;

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
                    #20;
                end
                // process 2 (MOSI constriants timing)
                begin
                    if(ns == WRITE) begin // made it for one clock as to be write_add or write_data randomly
                        #20;
                        tr_tb.MOSI_write_con.constraint_mode(0); // Disable the constraint after 1 cycles
                    end
                end
                // process 3 (MOSI constriants timing)
                begin
                    if(ns == READ_ADD) begin // made it for two clocks to make the first two values of MOSI to be 2'b10 in case of read_add state 
                        #20;
                        if (constraint_done) tr_tb.MOSI_read_add_con.constraint_mode(0); // Disable the constraint after 1 cycles
                        constraint_done = 1; // defined in shared package
                        i++; // defined in shared package
                    end
                end
                // process 4 (MOSI constriants timing)
                begin
                    if(ns == READ_DATA) begin // made it for two clocks to make the first two values of MOSI to be 2'b11 in case of read_data state
                        #20;
                        if (constraint_done) tr_tb.MOSI_read_data_con.constraint_mode(0); // Disable the constraint after 1 cycles
                        constraint_done = 1; // defined in shared package
                    end
                end
                // process 5 (enable the constraint)
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
        //**************************************** Directed Tests ********************************\\
        // directed test to test MISO signal having the correct output when it is a real memory value rather than an unknown signal
        repeat(10) begin
            rst_n = 0;
            #20;
            rst_n = 1;
            ss_n = 0; //go to CHK_CMD state
            #20 MOSI = 1; //to decide it's a read address process
            sampling_MOSI = MOSI;
            #20 MOSI = 1; 
            sampling_MOSI = MOSI;
            #20 MOSI = 0; //the first two bits are 2'b10
            sampling_MOSI = MOSI;
            foreach(addresses_with_values[,j]) begin // to get the stored addresses to MISO
                #20 MOSI = addresses_with_values[q][j];
                sampling_MOSI = MOSI; // used in constrianting MOSI (defined in shared package)
            end
            q++; // counter q is declared in shared package
            #20 ss_n = 1; //end protocol             
            #60; //time to wait until the next process comes
            //addresses_with_values.delete(0); // delete the retrieved address to loop on all addresses once each
            //addresses_with_values.shuffle; // make it random

            ss_n = 0; //go to CHK_CMD state
            //fourth comes read data process
            #20 MOSI = 1; //to decide it's a read process
            sampling_MOSI = MOSI;
            #20 MOSI = 1; 
            sampling_MOSI = MOSI;
            #20 MOSI = 1; //the first two bits are 2'b11
            sampling_MOSI = MOSI;
            repeat(8) begin
                #20 MOSI = $random; //randomize the data as we won't use it (dummy data)
                sampling_MOSI = MOSI;
            end
            #200 ss_n = 1; //200 = 20 + (9 * 20) as we will wait for another nine clocks (one for tx_valid and 8 for tx_data to be serialized) and then end protocol
            #60 ; //time to wait until the next process comes
        end

        test_finished = 1; // end of test
    end
endmodule