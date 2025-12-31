`ifndef AXI_IF 
    `define AXI_IF

    interface axi_if #(parameter bit[7:0] ADDR_WIDTH = 32, parameter bit[7:0] DATA_WIDTH = 32) (
        input tri clk,
        input tri rst,
        // AXI Write Address Channel
        output logic [ADDR_WIDTH-1:0] awaddr,
        output logic [2:0] awprot,
        output logic awvalid,
        input logic awready,
        output logic [3:0] aw_transaction_id,
        // AXI Write Data Channel
        output logic [DATA_WIDTH-1:0] wdata,
        output logic [(DATA_WIDTH/8)-1:0] wstrb,
        output logic wlast,
        output logic wvalid,
        input logic wready,
        output logic [3:0] w_transaction_id,
        // AXI Write Response Channel
        input logic [1:0] bresp,
        input logic bvalid,
        output logic bready,    
        input logic [3:0] b_transaction_id,
        // AXI Read Address Channel
        output logic [ADDR_WIDTH-1:0] araddr,
        output logic [2:0] arprot,
        output logic arvalid,
        input logic arready,
        output logic [3:0] ar_transaction_id,
        // AXI Read Data Channel
        input logic [DATA_WIDTH-1:0] rdata,
        input logic [1:0] rresp,
        input logic rlast,
        input logic rvalid,
        output logic rready,
        input logic [3:0] r_transaction_id

    );

    modport AXI_Master (
        // AXI Write Address Channel
        output awaddr,
        output awprot,
        output awvalid,
        input awready,
        output aw_transaction_id,
        // AXI Write Data Channel
        output wdata,
        output wstrb,
        output wlast,
        output wvalid,
        input wready,
        output w_transaction_id,
        // AXI Write Response Channel
        input bresp,
        input bvalid,
        output bready,    
        input b_transaction_id,
        // AXI Read Address Channel
        output araddr,
        output arprot,
        output arvalid,
        input arready,
        output ar_transaction_id,
        // AXI Read Data Channel
        input rdata,
        input rresp,
        input rlast,
        input rvalid,
        output rready,
        input r_transaction_id
    );

    modport AXI_Slave (
        // AXI Write Address Channel
        input awaddr,
        input awprot,
        input awvalid,
        output awready,
        input aw_transaction_id,
        // AXI Write Data Channel
        input wdata,
        input wstrb,
        input wlast,
        input wvalid,
        output wready,
        input w_transaction_id,
        // AXI Write Response Channel
        output bresp,
        output bvalid,
        input bready,    
        output b_transaction_id,
        // AXI Read Address Channel
        input araddr,
        input arprot,
        input arvalid,
        output arready,
        input ar_transaction_id,
        // AXI Read Data Channel
        output rdata,
        output rresp,
        output rlast,
        output rvalid,
        input rready,
        output r_transaction_id
    );


    endinterface: axi_if

`endif