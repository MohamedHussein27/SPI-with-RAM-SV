package spi_slave_transaction_pkg;
    import spi_slave_shared_pkg::*;
    class SPI_SLAVE_transaction;
        bit clk;
        rand bit rst_n;
        rand bit MOSI;
        rand bit tx_valid;
        rand bit ss_n;
        rand bit [7:0] tx_data;
        logic MISO;
        logic rx_valid;
        logic [9:0] rx_data;

        bit read_add_array [2] = '{0, 1};


        // constraints
        constraint reset_con {
            rst_n dist {0:/1, 1:/99}; // reset is less to occur
        }

        constraint ss_n_con { // making ss_n high only in the end of each state
            if(state_finished){
                    ss_n == 1;
                }
                else{
                    ss_n == 0;
                }
        }
        
        // MOSI constraints
        constraint MOSI_write_con {
            if(ns == WRITE){
                MOSI == 0;
            }
        }
        constraint MOSI_read_add_con {
            if(ns == READ_ADD){
                MOSI == read_add_array[1-i];
            }
        }
        constraint MOSI_read_data_con {
            if(ns == READ_DATA){
                MOSI == 1;
            }
        }

        constraint tx_valid_con {
            if(tx_flag){
                tx_valid == 1;
            }
            else{
                tx_valid == 0;
            }
        }
        constraint MOSI_con {
            MOSI dist {0:/60, 1:/40}; // writing is more frequently than reading
        }
    endclass
endpackage