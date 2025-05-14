package ram_transaction_pkg;
    import shared_pkg::*;
    class RAM_transaction;
        bit clk;
        rand bit rst_n;
        rand bit rx_valid;
        rand bit [9:0] din;
        logic [7:0] dout;
        logic tx_valid;

        logic [7:0] temp_address; // will be used is equal address constraint

        // signlas for third constraint
        //bit wr_addr_done;
        //bit rd_addr_done;

        //RAM_scoreboard ram_scr_el = new; // instance of RAM_scoreboard class

        //wr_addr_done = ram_scr_el.wr_addr_done;
        //rd_addr_done = ram_scr_el.rd_addr_done;

        // constraints
        constraint reset_con {
            rst_n dist {0:/2, 1:/98}; // reset is less to occur
        }

        constraint rx_valid_con {
            rx_valid dist {0:/10, 1:/90}; // receive valid data more frequently
        }

        // now we want to make a constraint on din so we first write address then write data and vise versa with reading
        constraint din_con {
            din[9] dist {0:/65, 1:/35}; // writing is more frequently than reading
            din[8] dist {0:/55, 1:/45}; // writing address is more frequently than reading address

            /*if (din[9] == 0 && !wr_addr_done){
                din[8] == 0; // write address before write data
            }
            else if (din[9] == 1 && !rd_addr_done) {
                din[8] == 0; // read address before reading data
            }*/
        }

        // make the address of reading the same as the address of writing
        /*constraint equal_address {
            if (din[9] == 1'b0 && din[8] == 1'b0){
                temp_address == din[7:0];
            }
            else if (din[9] == 1'b0 && din[8] == 1'b1){
                din[7:0] == temp_address;
            }
        }*/
    endclass
endpackage
                
            
