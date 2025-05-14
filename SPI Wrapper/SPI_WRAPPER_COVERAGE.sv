package spi_wrapper_coverage_pkg;
    import spi_wrapper_transaction_pkg::*;
    class SPI_WRAPPER_coverage;
        // wrapper_transaction class object
        SPI_WRAPPER_transaction spi_wrapper_tr_el = new;

        // cover group
        covergroup SPI_WRAPPER_Cross_Group;
            // cover points
            cp_ss_n: coverpoint spi_wrapper_tr_el.ss_n{ // how many states started and ended
                bins state_start = (1 => 0);
                bins state_end   = (0 => 1);
            }
        endgroup

        // sample function
        function void sample_data(SPI_WRAPPER_transaction spi_wrapper_tr);
            spi_wrapper_tr_el = spi_wrapper_tr;
            SPI_WRAPPER_Cross_Group.sample();
        endfunction

        function new();
            SPI_WRAPPER_Cross_Group = new();
        endfunction
    endclass
endpackage