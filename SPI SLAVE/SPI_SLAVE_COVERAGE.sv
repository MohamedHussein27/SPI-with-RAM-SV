package spi_slave_coverage_pkg;
    import spi_slave_transaction_pkg::*;
    class SPI_SLAVE_coverage;
        // slave_transaction class object
        SPI_SLAVE_transaction spi_slave_tr_el = new;

        // cover group
        covergroup SPI_SLAVE_Cross_Group;
            // cover points
            cp_tx_valid: coverpoint spi_slave_tr_el.tx_valid;
            cp_tx_data: coverpoint spi_slave_tr_el.tx_data;
            cp_rx_valid: coverpoint spi_slave_tr_el.rx_valid;
            cp_ss_n: coverpoint spi_slave_tr_el.ss_n;
            cp_rx_data9: coverpoint spi_slave_tr_el.rx_data[9];
            cp_rx_data8: coverpoint spi_slave_tr_el.rx_data[8];
            // cross coverage
            wr_addr_C: cross cp_rx_data9, cp_rx_data8, cp_rx_valid { // write address corss
                bins wr_addr = binsof(cp_rx_data9) intersect {0} && binsof(cp_rx_data8) intersect {0} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0; // we only want to cover write address condition
            }
            rd_addr_C: cross cp_rx_data9, cp_rx_data8, cp_rx_valid { // read address corss
                bins rd_addr = binsof(cp_rx_data9) intersect {1} && binsof(cp_rx_data8) intersect {0} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
            wr_data_C: cross cp_rx_data9, cp_rx_data8, cp_rx_valid { // write data corss
                bins wr_data = binsof(cp_rx_data9) intersect {0} && binsof(cp_rx_data8) intersect {1} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
            rd_data_C: cross cp_rx_data9, cp_rx_data8, cp_rx_valid { // read data corss
                bins rd_data = binsof(cp_rx_data9) intersect {1} && binsof(cp_rx_data8) intersect {1} && binsof(cp_rx_valid) intersect {1};
                option.cross_auto_bin_max = 0;
            }
            receive_C: cross cp_tx_valid, cp_tx_data { // when tx_valid is high we should receive tx_data
                bins receive = binsof(cp_tx_valid) intersect {1} && binsof(cp_tx_data);
                option.cross_auto_bin_max = 0;
            }
        endgroup

        // sample function
        function void sample_data(SPI_SLAVE_transaction spi_slave_tr);
            spi_slave_tr_el = spi_slave_tr;
            SPI_SLAVE_Cross_Group.sample();
        endfunction

        function new();
            SPI_SLAVE_Cross_Group = new();
        endfunction
    endclass
endpackage