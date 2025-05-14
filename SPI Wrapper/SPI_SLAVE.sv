module SPI_SLAVE(spi_slave_if.DUT spi_slaveif);
    logic clk;
    logic rst_n;
    logic MOSI;
    logic tx_valid;
    logic ss_n;
    logic [7:0] tx_data;
    logic MISO;
    logic rx_valid;
    logic [9:0] rx_data;

    // assigning signals to be interfaced
    // inputs
    assign clk = spi_slaveif.clk;
    assign rst_n = spi_slaveif.rst_n;
    assign MOSI = spi_slaveif.MOSI;
    assign tx_valid = spi_slaveif.tx_valid;
    assign ss_n = spi_slaveif.ss_n;
    assign tx_data = spi_slaveif.tx_data;
    // outputs
    assign spi_slaveif.MISO = MISO;
    assign spi_slaveif.rx_valid = rx_valid;
    assign spi_slaveif.rx_data  = rx_data;



    localparam IDLE = 3'b000,
            CHK_CMD = 3'b001,
            WRITE = 3'b010,
            READ_ADD = 3'b011,
            READ_DATA = 3'b100;

    reg [2:0] cs , ns ; ///current state and next state           
    reg ADD_DATA_checker ; //if it's set to high then we will go to READ_ADD state and we will go READ_DATA state otherwise
    reg [3:0] counter1 ; //a counter to fill the rx_data (general counter)
    reg [2:0] counter2 ; //specific counter for the READ_DATA state
    reg [9:0] bus ; // an internal signal to be filled and then assigned to rx_data so the data can be sent in parallel

    // assertions
    // assertions for next state

    // check the value of the current state when reset is asserted
    property rst_n_ns_p;
        @(posedge clk) (!rst_n) |=> (cs == IDLE);
    endproperty

    // ensure FSM transitions correctly from IDLE to CHK_CMD when ss_n is deasserted
    property idle_to_chk_cmd_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == IDLE && !ss_n) |=> (cs == CHK_CMD);
    endproperty

    // ensure FSM transitions from CHK_CMD to WRITE when MOSI is 0
    property chk_cmd_to_write_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == CHK_CMD && !ss_n && MOSI == 0) |=> (cs == WRITE);
    endproperty

    // ensure FSM transitions from CHK_CMD to READ_ADD when MOSI is 1 and ADD_DATA_checker is 1
    property chk_cmd_to_read_add_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == CHK_CMD && !ss_n && MOSI == 1 && ADD_DATA_checker == 1) |=> (cs == READ_ADD);
    endproperty
    
    // ensure FSM transitions from CHK_CMD to READ_DATA when MOSI is 1 and ADD_DATA_checker is 0
    property chk_cmd_to_read_data_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == CHK_CMD && !ss_n && MOSI == 1 && ADD_DATA_checker == 0) |=> (cs == READ_DATA);
    endproperty    

    // ensure FSM remains in WRITE unless ss_n is asserted
    property write_hold_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == WRITE && !ss_n) |=> (cs == WRITE);
    endproperty   

    // esure FSM transitions from WRITE to IDLE when ss_n is asserted or counter1 reaches max
    property write_to_idle_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == WRITE && ss_n) |=> (cs == IDLE);
    endproperty   

    // ensure FSM remains in READ_ADD unless ss_n is asserted
    property read_add_hold_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_ADD && !ss_n) |=> (cs == READ_ADD);
    endproperty   

    // ensure FSM transitions from READ_ADD to IDLE when ss_n is asserted or counter1 reaches max
    property read_add_to_idle_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_ADD && ss_n) |=> (cs == IDLE);
    endproperty
    
    // ensure FSM remains in READ_DATA unless ss_n is asserted
    property read_data_hold_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_DATA && !ss_n) |=> (cs == READ_DATA);
    endproperty
    
    // ensure FSM transitions from READ_DATA to IDLE when ss_n is asserted
    property read_data_to_idle_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_DATA && ss_n) |=> (cs == IDLE);
    endproperty
    

    `ifdef SIM
        rst_n_ns_a: assert property (rst_n_ns_p);
        idle_to_chk_cmd_a: assert property (idle_to_chk_cmd_p);
        chk_cmd_to_write_a: assert property (chk_cmd_to_write_p);
        chk_cmd_to_read_add_a: assert property (chk_cmd_to_read_add_p);
        chk_cmd_to_read_data_a: assert property (chk_cmd_to_read_data_p);
        write_hold_a: assert property (write_hold_p);
        write_to_idle_a: assert property (write_to_idle_p);
        read_add_hold_a: assert property (read_add_hold_p);
        read_add_to_idle_a: assert property (read_add_to_idle_p);
        read_data_hold_a: assert property (read_data_hold_p);
        read_data_to_idle_a: assert property (read_data_to_idle_p);
    `endif
    
    rst_n_ns_c: cover property (rst_n_ns_p);
    idle_to_chk_cmd_c: cover property (idle_to_chk_cmd_p);
    chk_cmd_to_write_c: cover property (chk_cmd_to_write_p);
    chk_cmd_to_read_add_c: cover property (chk_cmd_to_read_add_p);
    chk_cmd_to_read_data_c: cover property (chk_cmd_to_read_data_p);
    write_hold_c: cover property (write_hold_p);
    write_to_idle_c: cover property (write_to_idle_p);
    read_add_hold_c: cover property (read_add_hold_p);
    read_add_to_idle_c: cover property (read_add_to_idle_p);
    read_data_hold_c: cover property (read_data_hold_p);
    read_data_to_idle_c: cover property (read_data_to_idle_p);



    





    //state memory 
    always @(posedge clk)
    begin
        if(~rst_n) 
            cs <= IDLE;
        else 
            cs <= ns ;
    end

    //next state logic
    always @(*) begin
        ns = cs ;
        case(cs)
            IDLE : begin
                if(ss_n)
                    ns = IDLE;
                else    
                    ns = CHK_CMD;
            end
            CHK_CMD : begin
                if(ss_n)
                    ns = IDLE;
                else begin
                    if((~ss_n) && (MOSI == 0))
                        ns = WRITE;
                    else if ((~ss_n) && (MOSI == 1) && (ADD_DATA_checker == 1))
                        ns = READ_ADD;
                    else if ((~ss_n) && (MOSI == 1) && (ADD_DATA_checker == 0))
                        ns = READ_DATA;
                end
            end
            WRITE : begin
                if(ss_n) //counter = -1(4'b1111 = -1) means that the whole rx_bus is completed so go to state IDLE
                    ns = IDLE;
                else 
                    ns = WRITE;
            end
            READ_ADD : begin 
                if(ss_n)
                    ns = IDLE;     
                else
                    ns = READ_ADD;
            end
            READ_DATA : begin        
                if(ss_n)
                    ns = IDLE;
                else
                    ns = READ_DATA;
            end
        endcase
    end

    // assertions for output logic
    // check the value of rx_data, rx_valid and MISO when reset
    property rst_n_o_p;
        @(posedge clk) (!rst_n) |=> ((rx_data == 0) && (!rx_valid) && (!MISO));
    endproperty

    // check the value of rx_valid when cs is IDLE
    property idle_o_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == IDLE) |=> (!rx_valid);
    endproperty

    // check the value of rx_data, rx_valid when cs is WRITE and counter is maxed
    property write_o_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == WRITE) && (counter1 == 4'hf) |=> $rose(rx_valid) && (rx_data == bus) |=> $fell(rx_valid);
    endproperty

    // check the value of rx_data, rx_valid and ADD_DATA_checker when cs is READ_ADD and counter is maxed
    property read_add_o_p;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_ADD) && (counter1 == 4'hf) |=> $rose(rx_valid) && (rx_data == bus) && $fell(ADD_DATA_checker) |=> $fell(rx_valid);
    endproperty

    // check the value of rx_valid when cs is READ_DATA and the first counter is maxed
    property read_data_o_p_1;  
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_DATA) && (counter1 == 4'hf) |=> $rose(rx_valid) && (rx_data == bus) |=> $fell(rx_valid);
    endproperty

    // check the value of MISO when cs is READ_DATA and tx_valid is high
    property read_data_o_p_2;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_DATA) && (tx_valid) |=> (MISO == tx_data[$past(counter2)]);
    endproperty

    // check the value of ADD_DATA_checker when cs is READ_DATA and counter2 is maxed
    property read_data_o_p_3;
        @(posedge clk) disable iff (rst_n == 0) (cs == READ_DATA) && (counter2 == 3'b111) |=> $rose(ADD_DATA_checker);
    endproperty

    // Garded assertions
    `ifdef SIM
        rst_n_o_a: assert property (rst_n_o_p);
        idle_o_a: assert property (idle_o_p);
        write_o_a: assert property (write_o_p);
        read_add_o_a: assert property (read_add_o_p);
        read_data_o_a_1: assert property (read_data_o_p_1);
        read_data_o_a_2: assert property (read_data_o_p_2);
        read_data_o_a_3: assert property (read_data_o_p_3);
    `endif
    // cover assertions
    rst_n_o_c: cover property (rst_n_o_p);
    idle_o_c:  cover property (idle_o_p );
    write_o_c: cover property (write_o_p);
    read_add_o_c: cover property (read_add_o_p);
    read_data_o_c_1: cover property (read_data_o_p_1);
    read_data_o_c_2: cover property (read_data_o_p_2);
    read_data_o_c_3: cover property (read_data_o_p_3);


    //output logic 
    always @(posedge clk) begin
        if (~rst_n) begin
            counter1 <= 9; //as the first bit entered will be the MSB
            counter2 <= 7; // as the first bit outted will be the MSB
            ADD_DATA_checker <= 1; // as reading address first is the default
            bus <= 0;
            rx_data <= 0;
            rx_valid <= 0; 
            MISO  <= 0; // making the default output is zero
        end
        //IDLE state
        else begin
            if(cs == IDLE) begin
                rx_valid <= 0;
                counter1 <= 9 ; //to start the same proccess in other states without resetting
                counter2 <= 7 ; 
                MISO <= 0;
            end
            //WRITE state
            else if(cs == WRITE) begin
                if (counter1 >= 0)begin
                    bus[counter1] <= MOSI;
                    counter1 <= counter1 - 1;   //decrement the counter to fill the whole output rx_data
                end
                if(counter1 == 4'b1111) begin//(4'b1111) means that the counter has the value -1 (the rx_data is completed)
                    rx_valid <= 1;
                    rx_data <= bus ; //sending the parallel data to the spi_slave
                end
            end
            //READ_ADD state  (mostly the same as WRITE state)
            else if (cs == READ_ADD) begin
                if (counter1 >= 0)begin
                    bus[counter1] <= MOSI;
                    counter1 <= counter1 - 1;   //decrement the counter to fill the whole output rx_data
                end
                if(counter1 == 4'b1111) begin//(4'b1111) means that the counter has the value -1 (the rx_data is completed)
                    rx_valid <= 1;
                    rx_data <= bus ; //sending the parallel data to the spi_slave
                    ADD_DATA_checker <= 0; //(means that the read address is recieved) as when this state ends we will go to the READ_DATA state 
                end
            end
            //READ_DATA state  
            else if (cs == READ_DATA) begin
                if (counter1 >= 0)begin
                    bus[counter1] <= MOSI;
                    counter1 <= counter1 - 1;   //decrement the counter to fill the whole output rx_data
                end
                if(counter1 == 4'b1111) begin//(4'b1111) means that the counter has the value -1 (the rx_data is completed)
                    rx_valid <= 1;
                    rx_data <= bus ; //sending the parallel data to the spi_slave
                    counter1 <= 9 ; //only and only in this case we will reset the counter as we won't go back to the IDLE state until the process ends
                end
                if(rx_valid  == 1) rx_valid <= 0; //only and only in this case we will reset the rx_valid as we won't go back to the IDLE state until the process ends
                if(tx_valid==1 && counter2 >=0)begin
                    MISO <= tx_data[counter2] ; //counter-2 as it it's an 8 bit bus not 10 bit bus 
                    counter2 <= counter2 - 1 ;
                end
                if(counter2 == 3'b111)begin
                    ADD_DATA_checker <= 1; //(means that we should send another address for reading in the next time) so we will go to READ_ADD state
                end
            end
        end

    end
endmodule