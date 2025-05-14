package ram_coverage_pkg;
    import ram_transaction_pkg::*;
    class RAM_coverage;
        // ram_transaction class object
        RAM_transaction ram_tr_el = new;

        // cover group
        covergroup RAM_Cross_Group;
            // cover points
            cp_tx_valid: coverpoint ram_tr_el.tx_valid;
            cp_rx_valid: coverpoint ram_tr_el.rx_valid;
            cp_din9: coverpoint ram_tr_el.din[9];
            cp_din8: coverpoint ram_tr_el.din[8];
            // cross coverage
            wr_addr_C: cross cp_din9, cp_din8, cp_rx_valid { // write address corss
                bins wr_addr = binsof(cp_din9) intersect {0} && binsof(cp_din8) intersect {0} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0; // we only want to cover write address condition
            }
            rd_addr_C: cross cp_din9, cp_din8, cp_rx_valid { // read address corss
                bins rd_addr = binsof(cp_din9) intersect {1} && binsof(cp_din8) intersect {0} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
            wr_data_C: cross cp_din9, cp_din8, cp_rx_valid { // write data corss
                bins wr_data = binsof(cp_din9) intersect {0} && binsof(cp_din8) intersect {1} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
            rd_data_C: cross cp_din9, cp_din8, cp_rx_valid, cp_tx_valid { // read data corss
                bins rd_data = binsof(cp_din9) intersect {1} && binsof(cp_din8) intersect {1} && binsof(cp_rx_valid) intersect {1} && binsof(cp_tx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
        endgroup

        // sample function
        function void sample_data(RAM_transaction ram_tr);
            ram_tr_el = ram_tr;
            RAM_Cross_Group.sample();
        endfunction

        function new();
            RAM_Cross_Group = new();
        endfunction
    endclass
endpackage
