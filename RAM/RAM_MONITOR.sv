import ram_transaction_pkg::*;
import ram_coverage_pkg::*;
import ram_scoreboard_pkg::*;
import shared_pkg::*;
module ram_monitor (ram_if.MONITOR ramif);
    RAM_transaction tr_mon = new; // transaction object
    RAM_coverage cov_mon = new; // coverage object
    RAM_scoreboard scb_mon = new; // scoreboard object

    initial begin 
        forever begin
            #20; // negedge
            // assigning interface data to class transaction object
            tr_mon.rst_n = ramif.rst_n;
            tr_mon.rx_valid = ramif.rx_valid;
            tr_mon.din = ramif.din;
            tr_mon.dout = ramif.dout;
            tr_mon.tx_valid = ramif.tx_valid;
            // two parallel processes
            fork
                // process 1
                cov_mon.sample_data(tr_mon);
                // process 2
                scb_mon.check_data(tr_mon);
            join
            if (test_finished) begin
                $display("error count = %0d, correct count = %0d", error_count_out, correct_count_out);
                $stop;
            end
        end
    end
endmodule
        