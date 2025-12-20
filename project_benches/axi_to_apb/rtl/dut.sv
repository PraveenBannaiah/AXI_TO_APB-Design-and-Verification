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
    
    //W Channel
    input logic [ADDR_WIDTH:0] wdata,
    input logic wvalid,
    output logic wready,
    input logic wlast,

    //B Channel
    input logic bready,
    output logic bvalid,
    output logic [1:0] bresp,     //00: OKAY, 01: EXOKAY, 10: SLVERR, 11: DECERR

    //AR Channel
    input logic [DATA_WIDTH:0] araddr,
    input logic arvalid,
    output logic arready,

    //R Channel
    input logic rready,
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
        B_VALID    = 2'b01,
        B_READY    = 2'b10
    } b_state_t;

    b_state_t b_current_state, b_next_state;

    //AR Channel state machine
    typedef enum logic [1:0] {
        AR_IDLE     = 2'b00,
        AR_VALID    = 2'b01,
        AR_READY    = 2'b10
    } ar_state_t;   
    
    ar_state_t ar_current_state, ar_next_state;

    //R Channel state machine
    typedef enum logic [1:0] {      
        R_IDLE     = 2'b00,
        R_VALID    = 2'b01,
        R_READY    = 2'b10
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

            end
            AW_READY: begin
                awready = 1'b1;
                aw_next_state = AW_SAMPLE;
            end

            AW_SAMPLE: begin
                //Sample the address and store in in the buffer
                //Add support for multiple/burst transactions later

            end

        endcase

    end


endmodule

