`ifndef APB_IF_SV
    `define APB_IF_SV

    interface apb_if#(parameter int ADDR_WIDTH = 32, int DATA_WIDTH = 31)(
        inout tri pclk,
        inout tri presetn,
        inout tri [7:0] psel,    //Currently supporting 8 slaves
        inout tri [ADDR_WIDTH - 1:0] paddr,
        inout tri pwrite,
        inout tri penable,
        inout tri [DATA_WIDTH - 1:0] pwdata,
        inout tri [DATA_WIDTH - 1:0] prdata,
        inout tri pready,
        inout tri pslverr
    )

    modport APB_Master (
        inout pclk,
        inout presetn,
        output psel,
        output paddr,
        output pwrite,
        output penable,
        output pwdata,
        input prdata,
        input pready,
        input pslverr
    );

    modport APB_Slave (
        inout pclk,
        inout presetn,
        input psel,
        input paddr,
        input pwrite,
        input penable,
        input pwdata,
        output prdata,
        output pready,
        output pslverr
    );

    endinterface

`endif