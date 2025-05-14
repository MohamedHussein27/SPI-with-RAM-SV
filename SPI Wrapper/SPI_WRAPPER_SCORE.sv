package spi_wrapper_scoreboard_pkg;
    import spi_wrapper_transaction_pkg::*;
    import spi_wrapper_shared_pkg::*;
    class SPI_WRAPPER_scoreboard;
        parameter MEM_DEPTH = 256;
        parameter ADDR_SIZE = 8;
        // internal signals
        // spi slave signals
        bit DATA_or_ADD; // indicates whether its read data or read address state
        reg queue_store[$]; // to store data
        logic [3:0] size; // to indicate the size of the queue 
        logic [9:0] rx_data_ref;
        logic rx_valid_ref;

        // ram signals
        logic [ADDR_SIZE-1:0] ref_mem [MEM_DEPTH]; // fixed array to verify RAM 
        logic [7:0] r_addr_ref, w_addr_ref;
        logic [7:0] tx_data_ref;
        logic tx_valid_ref;

        // reference signals
        logic MISO_ref;

        // Compare function
        function void check_data (SPI_WRAPPER_transaction tr);
            reference_model(tr);
            // Compare MISO
            if (tr.MISO !== MISO_ref) begin
                error_count_MISO++;
                $display("Error in MISO at %0d", error_count_MISO);
            end else begin
                correct_count_MISO++;
            end
        endfunction

         // Reference model
        function void reference_model (SPI_WRAPPER_transaction tr_ref);
            // RAM
            if (rx_valid_ref) begin
                if (rx_data_ref[9:8] == 2'b00) begin // write address
                    w_addr_ref = rx_data_ref[7:0];
                    tx_valid_ref = 1'b0;
                    if (k < 10)
                        addresses_with_values[k] = rx_data_ref[7:0]; // defined in shared package
                    k++;
                end
                else if (rx_data_ref[9:8] == 2'b01) begin // write data
                    ref_mem[w_addr_ref] = rx_data_ref[7:0];
                    tx_valid_ref = 1'b0;
                end
                else if (rx_data_ref[9:8] == 2'b10) begin // read address
                    r_addr_ref = rx_data_ref[7:0];
                    tx_valid_ref = 1'b0;
                end
                else if (rx_data_ref[9:8] == 2'b11) begin // read data
                    tx_data_ref = ref_mem[r_addr_ref];
                    tx_valid_ref = 1'b1;
                end
            end
            // output logic
            if (!tr_ref.rst_n) begin
                rx_data_ref = 0;
                rx_valid_ref = 1'b0;
                MISO_ref = 1'b0;
                DATA_or_ADD = 1'b0; // read address comes first
                counter = 0; // defined in shared package
                queue_store.delete(); // deleting queue
                size = 0;
                state_finished = 0; // defined in shared package
                cs = IDLE;
                ns = IDLE;
                delay = 1; // defined in shared package
                MISO_delay = 1; // defined in shared package
                // RAM signals
                tx_data_ref = 8'h00;
                tx_valid_ref = 1'b0;
                r_addr_ref = 8'h00;
                w_addr_ref = 8'h00;
            end
            else begin 
                if(cs == IDLE) begin
                    rx_valid_ref = 1'b0;
                    queue_store.delete(); // deleting queue
                    size = 0;
                    counter = 0; // defined in shared package
                    MISO_ref = 1'b0; 
                    state_finished = 0; // defined in shared package
                    ns = IDLE;
                    MISO_delay = 1; // defined in shared package
                end
                else if(cs == WRITE || cs == READ_ADD) begin
                    queue_store.push_back(tr_ref.MOSI); // filling queue
                    size = queue_store.size();
                    if (size == 9) state_finished = 1; // defined in shared package
                    if (size == 11) begin // the data is ready at size = 10 but we used size = 11 to add a delay to match the dut
                        rx_valid_ref = 1'b1;
                        //rx_data_ref = queue_store; // wrong assignment
                        for (int i = 0; i < 10; i++) begin
                            //rx_data_ref[i] = queue_store[i]; // assign each bit from queue to rx_data
                            rx_data_ref[9-i] = queue_store.pop_front(); // evacuating queue
                        end
                        if (cs == READ_ADD) DATA_or_ADD = 1'b1; // it's READ_DATA state turn
                    end
                end
                else if(cs == READ_DATA) begin
                    if(rx_valid_ref) rx_valid_ref = 0; // put it first to consider the clock delay
                    if(tx_valid_ref) begin
                        if (MISO_delay)
                            MISO_delay = 0;
                        else begin
                            MISO_ref = tx_data_ref[7 - counter]; // MSB first
                            counter++;
                        end
                        if (counter == 7) begin
                            DATA_or_ADD = 1'b0; // it's READ_ADD state turn
                            state_finished = 1; // defined in shared package
                        end
                    end  
                    else begin
                        queue_store.push_back(tr_ref.MOSI); // filling queue
                        size = queue_store.size();
                        if (size == 11) begin // the data is ready at size = 10 but we used size = 11 to add a delay to match the dut
                            rx_valid_ref = 1'b1;
                            for (int i = 0; i < 10; i++) begin
                                rx_data_ref[9-i] = queue_store.pop_front(); // assign each bit from queue to rx_data
                            end
                        end
                    end                 
                end
            end
            // next state logic (written upside down to consider the clock delay)
            if (cs == WRITE) begin
                if (tr_ref.ss_n) cs = IDLE;
                else cs = WRITE;
            end
            else if (cs == READ_ADD) begin
                if (tr_ref.ss_n) cs = IDLE;
                else cs = READ_ADD;
            end
            else if (cs == READ_DATA) begin
                if (tr_ref.ss_n) cs = IDLE;
                else cs = READ_DATA;
            end
            else if (cs == CHK_CMD) begin
                if (tr_ref.ss_n) cs = IDLE;
                else if (!tr_ref.ss_n && !tr_ref.MOSI) cs = WRITE;
                else if (!tr_ref.ss_n && tr_ref.MOSI && !DATA_or_ADD) cs = READ_ADD;
                else if (!tr_ref.ss_n && tr_ref.MOSI && DATA_or_ADD) cs = READ_DATA;
            end
            else if (cs == IDLE) begin
                if (delay) cs = IDLE; // flag delay is defined in shared package
                else if (tr_ref.ss_n) cs = IDLE;
                else if (!tr_ref.ss_n) cs = CHK_CMD;
                delay = 0; // cancelling delay as we need it only for one clock tick
            end
        endfunction
        // this is next state logic for the three main states, i added this function to help in constrianting MOSI
        function void next_state (SPI_WRAPPER_transaction tr_ref_2);
            if (cs == CHK_CMD) begin
                if (tr_ref_2.ss_n) ns = IDLE;
                else if (!tr_ref_2.ss_n && !sampling_MOSI) ns = WRITE;
                else if (!tr_ref_2.ss_n && sampling_MOSI && !DATA_or_ADD) ns = READ_ADD;
                else if (!tr_ref_2.ss_n && sampling_MOSI && DATA_or_ADD) ns = READ_DATA;
            end
        endfunction
    endclass
endpackage

        