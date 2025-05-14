package spi_wrapper_shared_pkg;
    typedef enum {IDLE, CHK_CMD, WRITE, READ_ADD, READ_DATA} cs_e;
    cs_e cs; // i defined cs here so it can be accessed by both scoreboard and testbench
    cs_e ns; // next state logic
    logic sampling_MOSI; // used in next state logic
    int test_finished; // when high, stop the simulation
    logic [7:0] addresses_with_values [] = new[10]; // dynamic array take five address of w_add that has values in the ref mem to test the MOSI with real values other than unknown signal
    int k; // counter used to fill the dynamic array above
    int q; // counter to loop on each element in the dynamic array
    // internal signals
    int counter = 0; // counter used in reference model in READ_DATA state to verify MISO_ref Correctly
    bit state_finished; // when high, that means the current state is finished 
    bit delay; // just a falg to add 1 clock delay to synchronize between dut and reference model
    bit MISO_delay; // just a falg to add 1 clock delay to synchronize MISO signal in DUT and ref model 
    bit constraint_done; // flag to make MOSI constraint lasts for two clock cycles in case of READ_ADD & READ_DATA states
    int i; // counter used in reaad_add constriant
    // counters
    int correct_count_MISO = 0;
    int error_count_MISO = 0;
endpackage