package AXI_to_APB;
    parameter int ADDRESS_WIDTH = 32;
    parameter int DATA_WIDTH = 32;
    typedef struct packed{
        bit [ADDRESS_WIDTH - 1:0] awaddr;                //Write Address
        bit [ADDRESS_WIDTH - 1:0] araddr;                //Read Address
        bit read_write_flag;              //Flag to indicate read or write operation
        bit [3:0] transaction_id;          
    }addr_t;


    typedef struct packed{
        bit [DATA_WIDTH - 1:0] wdata;                 //Write Data
        bit [DATA_WIDTH - 1:0] rdata;                 //Read Data
        bit [3:0]  transaction_id;        //Transaction ID
        bit read_write_flag;              //Flag to indicate read or write operation
        bit last_flag;                    //Flag to indicate the last data transfer       
    }axi_tran_t;

endpackage