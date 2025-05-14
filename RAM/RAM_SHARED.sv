// this package has the shared signals among packages
package shared_pkg;
    int test_finished; // when high, stop the simulation
    // counters
    int error_count_out = 0; 
    int correct_count_out = 0;
    int error_count_tx_valid = 0;
    int correct_count_tx_valid = 0;
    // flags
    bit wr_addr_done = 0;
    bit rd_addr_done = 0; // flags to indicate write address and read address
endpackage