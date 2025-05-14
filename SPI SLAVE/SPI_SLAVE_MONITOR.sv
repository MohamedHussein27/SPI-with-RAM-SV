import spi_slave_transaction_pkg::*;
import spi_slave_coverage_pkg::*;
import spi_slave_scoreboard_pkg::*;
import spi_slave_shared_pkg::*;
module spi_slave_monitor (spi_slave_if.MONITOR spi_slaveif);
    SPI_SLAVE_transaction tr_mon = new; // transaction object
    SPI_SLAVE_coverage cov_mon = new; // coverage object
    SPI_SLAVE_scoreboard scb_mon = new; // scoreboard object

    initial begin 
        forever begin
            #10; // posedge
            // two parallel processes
            fork
                // process 1 ( sending data at negedge)
                begin
                    #10; // negedge
                    // assigning interface data to class transaction object
                    tr_mon.rst_n = spi_slaveif.rst_n;
                    tr_mon.MOSI = spi_slaveif.MOSI;
                    tr_mon.tx_valid = spi_slaveif.tx_valid;
                    tr_mon.ss_n = spi_slaveif.ss_n;
                    tr_mon.tx_data = spi_slaveif.tx_data;
                    tr_mon.MISO = spi_slaveif.MISO;
                    tr_mon.rx_valid = spi_slaveif.rx_valid;
                    tr_mon.rx_data  = spi_slaveif.rx_data;
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
sim:/spi_slave_top/dut/IDLE \
sim:/spi_slave_top/dut/CHK_CMD \
sim:/spi_slave_top/dut/WRITE \
sim:/spi_slave_top/dut/READ_ADD \
sim:/spi_slave_top/dut/READ_DATA \
sim:/spi_slave_top/dut/clk \
sim:/spi_slave_top/dut/rst_n \
sim:/spi_slave_top/dut/MOSI \
sim:/spi_slave_top/dut/tx_valid \
sim:/spi_slave_top/dut/ss_n \
sim:/spi_slave_top/dut/tx_data \
sim:/spi_slave_top/dut/MISO \
sim:/spi_slave_top/dut/rx_valid \
sim:/spi_slave_top/dut/rx_data \
sim:/spi_slave_top/dut/cs \
sim:/spi_slave_top/dut/ns \
sim:/spi_slave_top/dut/ADD_DATA_checker \
sim:/spi_slave_top/dut/counter1 \
sim:/spi_slave_top/dut/counter2 \
sim:/spi_slave_top/dut/bus
add wave -position insertpoint  \
sim:/spi_slave_top/MONITOR/scb_mon.DATA_or_ADD \
sim:/spi_slave_top/MONITOR/scb_mon.queue_store \
sim:/spi_slave_top/MONITOR/scb_mon.size \
sim:/spi_slave_top/MONITOR/scb_mon.rx_data_ref \
sim:/spi_slave_top/MONITOR/scb_mon.rx_valid_ref \
sim:/spi_slave_top/MONITOR/scb_mon.MISO_ref
add wave -position insertpoint  \
sim:/spi_slave_shared_pkg::cs \
sim:/spi_slave_shared_pkg::ns \
sim:/spi_slave_shared_pkg::sampling_MOSI \
sim:/spi_slave_shared_pkg::test_finished \
sim:/spi_slave_shared_pkg::counter \
sim:/spi_slave_shared_pkg::state_finished \
sim:/spi_slave_shared_pkg::tx_flag \
sim:/spi_slave_shared_pkg::delay \
sim:/spi_slave_shared_pkg::correct_count_rx_data \
sim:/spi_slave_shared_pkg::error_count_rx_data \
sim:/spi_slave_shared_pkg::correct_count_rx_valid \
sim:/spi_slave_shared_pkg::error_count_rx_valid \
sim:/spi_slave_shared_pkg::correct_count_MISO \
sim:/spi_slave_shared_pkg::error_count_MISO
restart
run -all
*/