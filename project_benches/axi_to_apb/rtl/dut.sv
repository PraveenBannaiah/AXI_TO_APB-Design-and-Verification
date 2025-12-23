//Praveen Bannaiah
//Design of AXI to APB Bridge DUT

module AXI_to_APB_Bridge_DUT 
    #(parameter bit[31:0] ADDR_WIDTH = 32, parameter bit[31:0] DATA_WIDTH = 32, 
      parameter bit[3:0] outstandin_transactions = 16) 
    (
    input logic clk,
    input logic reset_n,

    //AXI
    //AW Channel
    input logic [ADDR_WIDTH:0] awaddr,
    input logic awvalid,
    output logic awready,
    input logic [3:0] aw_transaction_id,
    
    //W Channel
    input logic [ADDR_WIDTH:0] wdata,
    input logic wvalid,
    input logic [3:0] w_transaction_id,
    output logic wready,
    input logic wlast,

    //B Channel
    input logic bready,
    output logic bvalid,
    output logic [1:0] bresp,     //00: OKAY, 01: EXOKAY, 10: SLVERR, 11: DECERR
    output logic [3:0] b_transaction_id,

    //AR Channel
    input logic [DATA_WIDTH:0] araddr,
    input logic arvalid,
    input logic [3:0] ar_transaction_id,
    output logic arready,

    //R Channel
    input logic rready,
    output logic [3:0] r_transaction_id,
    output logic rvalid,
    output logic [DATA_WIDTH:0] rdata,
    output logic [1:0] rresp,     //00: OKAY, 01: EXOKAY, 10: SLVERR, 11: DECERR
    output logic rlast,



    //APB Signals
    output logic pclk,
    output logic preset_n,
    output logic penable,
    output logic pwrite,
    output logic [ADDR_WIDTH:0] paddr,
    output logic [DATA_WIDTH:0] pwdata,
    input logic [DATA_WIDTH:0] prdata,
    output logic [2:0] psel,       //8 slave devices
    input logic pready,
    input logic pslverr

);

    import AXI_to_APB::*;

    //Address channel state machine states
    typedef enum logic [1:0] {
        AW_IDLE     = 2'b00,
        AW_VALID    = 2'b01,
        AW_READY    = 2'b10,
        AW_SAMPLE   = 2'b11
    } addr_state_t;

    addr_state_t aw_current_state, aw_next_state;

    //W Chanel state machine
    typedef enum logic [1:0] {
        W_IDLE     = 2'b00,
        W_VALID    = 2'b01,
        W_READY    = 2'b10
        //W_LAST      = 2'b11
    } w_state_t;

    w_state_t w_current_state, w_next_state;

    //B Channel state machine
    typedef enum logic [1:0] {
        B_IDLE     = 2'b00,
        B_GET_RESPONSE    = 2'b01,
        B_RESPOND    = 2'b10
    } b_state_t;

    b_state_t b_current_state, b_next_state;

    //AR Channel state machine
    typedef enum logic [1:0] {
        AR_IDLE     = 2'b00,
        AR_VALID    = 2'b01,
        AR_READY    = 2'b10,
        AR_SAMPLE   = 2'b11
    } ar_state_t;   
    
    ar_state_t ar_current_state, ar_next_state;

    //R Channel state machine
    typedef enum logic [1:0] {      
        R_IDLE     = 2'b00,
        R_DATA    = 2'b01,
        R_VALID    = 2'b10  //FIXME: Add support for multiple/burst transactions later (RLAST)
       // R_LAST     = 2'b11
    } r_state_t;

    r_state_t r_current_state, r_next_state;


    //Buffers to store address and data transactions
    //Planning a ROB like structure for storing the address and data transactions
    addr_t Address_trans_buffer [outstandin_transactions - 1:0];
    logic [7:0] address_read_pointer, address_write_pointer;  //For now assuming max 8 bits => 2**8 entries
    logic address_read_phase_bit, address_write_phase_bit;
    axi_tran_t axi_trans_buffer [outstandin_transactions - 1:0];
    logic axi_read_pointer, axi_write_pointer;
    logic axi_read_phase_bit, axi_write_phase_bit;

    

    //Functions to manage the FIFOs
    function address_fifo_full;
        if(address_read_phase_bit != address_write_phase_bit && address_read_pointer == address_write_pointer)
            address_fifo_full = 1'b1;
        else
            address_fifo_full = 1'b0;
    endfunction

    function address_fifo_empty;
        if(address_read_phase_bit == address_write_phase_bit || address_read_pointer == address_write_pointer)
            address_fifo_empty = 1'b1;
        else
            address_fifo_empty = 1'b0;
    endfunction


    function axi_fifo_full;
        if(axi_read_phase_bit != axi_write_phase_bit && axi_read_pointer == axi_write_pointer)
            axi_fifo_full = 1'b1;
        else
            axi_fifo_full = 1'b0;
    endfunction

    function axi_fifo_empty;
        if(axi_read_phase_bit == axi_write_phase_bit || axi_read_pointer == axi_write_pointer)
            axi_fifo_empty = 1'b1;
        else
            axi_fifo_empty = 1'b0;  
    endfunction



    //Synchronous block to update the states with syynchronous reset
    always@(posedge clk) begin
        if(!reset_n)
            begin
                aw_current_state <= AW_IDLE;
                w_current_state <= W_IDLE;
                b_current_state <= B_IDLE;
                ar_current_state <= AR_IDLE;
                r_current_state <= R_IDLE;

                //reset the pointers
                address_read_pointer <= 8'b0;
                address_write_pointer <= 8'b0;
                address_read_phase_bit <= 1'b0; 
                address_write_phase_bit <= 1'b0;
                axi_read_pointer <= 8'b0;
                axi_write_pointer <= 8'b0;
                axi_read_phase_bit <= 1'b0;
                axi_write_phase_bit <= 1'b0;

            end
        else
            begin
                aw_current_state <= aw_next_state;
                w_current_state <= w_next_state;
                b_current_state <= b_next_state;
                ar_current_state <= ar_next_state;
                r_current_state <= r_next_state;
            end
    end


    always_comb begin

        //AW Channel State Machine
        case(aw_current_state)
            AW_IDLE: begin
                awready = 1'b0;
                if(awvalid)
                    aw_next_state = AW_VALID;
                else
                    aw_next_state = AW_IDLE;
            end

            AW_VALID: begin
                //check if we are ready to sample the address
                //Add FIFO check
                if (address_fifo_full()) begin
                    aw_next_state = AW_VALID;
                end
                else begin
                    aw_next_state = AW_READY;
                end

            end
            AW_READY: begin
                awready = 1'b1;
                aw_next_state = AW_SAMPLE;
            end

            AW_SAMPLE: begin
                //Sample the address and store in in the buffer
                //Add support for multiple/burst transactions later
                addr_t transaction;
                if(awaddr != 32'bz || awaddr != 32'bx) begin
                    transaction.awaddr = awaddr;
                    transaction.transaction_id = aw_transaction_id;
                    transaction.read_write_flag = 1'b1; //Write Operation
                    Address_trans_buffer[address_write_pointer++] = transaction;
                    
                    if (address_write_pointer == outstandin_transactions) begin
                        address_write_pointer = 8'b0;
                        address_write_phase_bit = ~address_write_phase_bit;
                    end 
                end

                aw_next_state = AW_IDLE;

            end

        endcase

    end


    always_comb begin
        //AR Channel State Machine
        case(ar_current_state)
            AR_IDLE: begin
                arready = 1'b0;
                if(arvalid)
                    ar_next_state = AR_VALID;
                else
                    ar_next_state = AR_IDLE;
            end

            AR_VALID: begin
                //check if we are ready to sample the address
                //Add FIFO check
                if (address_fifo_full()) begin
                    ar_next_state = AR_VALID;
                end
                else begin
                    ar_next_state = AR_READY;
                end

            end
            AR_READY: begin
                arready = 1'b1;
                ar_next_state = AR_SAMPLE;
            end

            AR_SAMPLE: begin
                //Sample the address and store in in the buffer              
                addr_t transaction;
                if(araddr != 32'bz || araddr != 32'bx) begin
                    transaction.araddr = araddr;
                    transaction.transaction_id = ar_transaction_id;
                    transaction.read_write_flag = 1'b0; //Read Operation
                    Address_trans_buffer[address_write_pointer++] = transaction;
                    
                    if (address_write_pointer == outstandin_transactions) begin
                        address_write_pointer = 8'b0;
                        address_write_phase_bit = ~address_write_phase_bit;
                    end 
                end

                ar_next_state = AR_IDLE;

            end

        endcase

    end


    always_comb begin
        //W Channel State Machine
        case(w_current_state)
            W_IDLE: begin
                //Check if we are ready to sample the data
                wready = 1'b0;
                if(axi_fifo_full()) begin
                    w_next_state = W_IDLE;
                end
                else begin
                    w_next_state = W_VALID;
                end

            end

            W_READY: begin
                wready = 1'b1;
                if(axi_fifo_full()) begin
                    w_next_state = W_IDLE;
                end
                else if(wvalid) begin
                    w_next_state = W_VALID;
                end
                else 
                    w_next_state = W_READY;
            end

            W_VALID:
            begin
                //Sample the data and store in the buffer
                axi_tran_t transaction;
                transaction.wdata = wdata;
                transaction.read_write_flag = 1'b1; //Write Operation
                transaction.transaction_id = w_transaction_id;

                axi_trans_buffer[axi_write_pointer++] = transaction;
                
                if (axi_write_pointer == outstandin_transactions) begin
                    axi_write_pointer = 8'b0;
                    axi_write_phase_bit = ~axi_write_phase_bit;
                end 


                if(wlast)
                    w_next_state = W_IDLE;
                else
                    w_next_state = W_READY;

            end
        endcase
        

    end



    always_comb begin

        //R Channel State Machine
        case(r_current_state)
            R_IDLE: begin
                rvalid = 1'b0;
                if(rready)
                    r_next_state = R_DATA;
                else
                    r_next_state = R_IDLE;
            end
            R_DATA: begin
                //Get response
                rvalid = 1'b1;
                rdata = prdata; //FIXME: Get actual response from APB
                rresp = 2'b00; //OKAY    //FIXME: Get actual response from APB
                
                r_next_state = R_IDLE;
                
            end

        endcase

    end

    always_comb begin

        //B Channel State Machine
        case(b_current_state)
            B_IDLE: begin
                bvalid = 1'b0;
                if(bready)
                    b_next_state = B_GET_RESPONSE;
                else
                    b_next_state = B_IDLE;
            end
            B_GET_RESPONSE: begin
                //Get response
                bvalid = 1'b1;
                 
                bresp = 2'b00; //OKAY    //FIX_ME: Get actual response from APB
                
                b_next_state = B_IDLE;
                
            end

        endcase

    end


endmodule

