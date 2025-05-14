import spi_wrapper_transaction_pkg::*;
import spi_wrapper_coverage_pkg::*;
import spi_wrapper_scoreboard_pkg::*;
import spi_wrapper_shared_pkg::*;
module spi_wrapper_monitor (spi_wrapper_if.MONITOR spi_wrapperif);
    SPI_WRAPPER_transaction tr_mon = new; // transaction object
    SPI_WRAPPER_coverage cov_mon = new; // coverage object
    SPI_WRAPPER_scoreboard scb_mon = new; // scoreboard object

    initial begin 
        forever begin
            #10; // posedge
            // two parallel processes
            fork
                // process 1 ( sending data at negedge)
                begin
                    #10; // negedge
                    // assigning interface data to class transaction object
                    tr_mon.rst_n = spi_wrapperif.rst_n;
                    tr_mon.MOSI = spi_wrapperif.MOSI;
                    tr_mon.ss_n = spi_wrapperif.ss_n;
                    tr_mon.MISO = spi_wrapperif.MISO;
                    // two parallel processes
                    fork
                        // process 1
                        cov_mon.sample_data(tr_mon);
                        // process 2
                        scb_mon.check_data(tr_mon);
                    join
                end
                // process 2 (sampling at posedge to make next state logic)
                begin
                    scb_mon.next_state(tr_mon);
                end
            join
            if (test_finished) begin
                $display("error count = %0d, correct count = %0d", error_count_MISO, correct_count_MISO);
                $stop;
            end
        end
    end
endmodule
/*
add wave -position insertpoint  \
sim:/spi_wrapper_top/dut/SPI/IDLE \
sim:/spi_wrapper_top/dut/SPI/CHK_CMD \
sim:/spi_wrapper_top/dut/SPI/WRITE \
sim:/spi_wrapper_top/dut/SPI/READ_ADD \
sim:/spi_wrapper_top/dut/SPI/READ_DATA \
sim:/spi_wrapper_top/dut/SPI/MOSI \
sim:/spi_wrapper_top/dut/SPI/tx_valid \
sim:/spi_wrapper_top/dut/SPI/clk \
sim:/spi_wrapper_top/dut/SPI/rst_n \
sim:/spi_wrapper_top/dut/SPI/ss_n \
sim:/spi_wrapper_top/dut/SPI/tx_data \
sim:/spi_wrapper_top/dut/SPI/MISO \
sim:/spi_wrapper_top/dut/SPI/rx_valid \
sim:/spi_wrapper_top/dut/SPI/rx_data \
sim:/spi_wrapper_top/dut/SPI/cs \
sim:/spi_wrapper_top/dut/SPI/ns \
sim:/spi_wrapper_top/dut/SPI/ADD_DATA_checker \
sim:/spi_wrapper_top/dut/SPI/counter1 \
sim:/spi_wrapper_top/dut/SPI/counter2 \
sim:/spi_wrapper_top/dut/SPI/bus
add wave -position insertpoint  \
sim:/spi_wrapper_top/dut/Ram/MEM_DEPTH \
sim:/spi_wrapper_top/dut/Ram/ADDR_SIZE \
sim:/spi_wrapper_top/dut/Ram/clk \
sim:/spi_wrapper_top/dut/Ram/rst_n \
sim:/spi_wrapper_top/dut/Ram/rx_valid \
sim:/spi_wrapper_top/dut/Ram/din \
sim:/spi_wrapper_top/dut/Ram/dout \
sim:/spi_wrapper_top/dut/Ram/tx_valid \
sim:/spi_wrapper_top/dut/Ram/memory \
sim:/spi_wrapper_top/dut/Ram/addr_wr \
sim:/spi_wrapper_top/dut/Ram/addr_re
add wave -position insertpoint  \
sim:/spi_wrapper_top/MONITOR/tr_mon \
sim:/spi_wrapper_top/MONITOR/cov_mon \
sim:/spi_wrapper_top/MONITOR/scb_mon \
sim:/spi_wrapper_top/MONITOR/scb_mon.DATA_or_ADD \
sim:/spi_wrapper_top/MONITOR/scb_mon.size \
sim:/spi_wrapper_top/MONITOR/scb_mon.rx_data_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.rx_valid_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.ref_mem \
sim:/spi_wrapper_top/MONITOR/scb_mon.r_addr_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.w_addr_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.tx_data_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.tx_valid_ref \
sim:/spi_wrapper_top/MONITOR/scb_mon.MISO_ref \
add wave -position insertpoint  \
sim:/spi_wrapper_shared_pkg::cs \
sim:/spi_wrapper_shared_pkg::ns \
sim:/spi_wrapper_shared_pkg::sampling_MOSI \
sim:/spi_wrapper_shared_pkg::test_finished \
sim:/spi_wrapper_shared_pkg::addresses_with_values \
sim:/spi_wrapper_shared_pkg::k \
sim:/spi_wrapper_shared_pkg::counter \
sim:/spi_wrapper_shared_pkg::state_finished \
sim:/spi_wrapper_shared_pkg::delay \
sim:/spi_wrapper_shared_pkg::MISO_delay \
sim:/spi_wrapper_shared_pkg::constraint_done \
sim:/spi_wrapper_shared_pkg::i \
sim:/spi_wrapper_shared_pkg::correct_count_MISO \
sim:/spi_wrapper_shared_pkg::error_count_MISO \
add wave -position insertpoint  \
sim:/spi_wrapper_top/tb/test0 \
sim:/spi_wrapper_top/tb/test1 \
sim:/spi_wrapper_top/tb/test2 \
sim:/spi_wrapper_top/tb/test3 \
sim:/spi_wrapper_top/tb/test4
restart
*/