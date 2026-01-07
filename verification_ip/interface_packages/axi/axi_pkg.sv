`ifndef AXI_PKG_SV
    `define AXI_PKG_SV

    `include "uvm_macros.svh"

    package axi_pkg;

        import uvm_pkg::*;
        `include "axi_transaction.svh"

    endpackage : axi_pkg
    
`endif