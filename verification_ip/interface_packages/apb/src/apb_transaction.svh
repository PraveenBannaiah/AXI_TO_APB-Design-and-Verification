`ifndef APB_TRANSACTION_SVH
    `define APB_TRANSACTION_SVH

    class apb_transaction extends uvm_sequence_item;

        // APB Signals
        rand bit [31:0] paddr;
        rand bit [31:0] pwdata;
        rand bit penable;
        rand bit pwrite;
        rand bit [7:0] psel;          //For 8 slaves
        rand bit [31:0] prdata;
        rand bit pready;
        rand bit pslverr;

        `uvm_object_utils(apb_transaction)   //Register with the factory

        function new(string name = "");
            super.new(name);
        endfunction : new

        virtual function string convert2string();
            return $sformatf("PADDR: %h, PWDATA: %h, PENABLE: %b, PWRITE: %b, PSEL: %b, PRDATA: %h, PREADY: %b, PSLVERR: %b",
                             paddr, pwdata, penable, pwrite, psel, prdata, pready, pslverr);
        endfunction : convert2string

        virtual function bit compare(uvm_object rhs);

            if($cast(this,rhs)) begin
                if( (this.paddr    !== rhs.paddr)    ||
                    (this.pwdata   !== rhs.pwdata)   ||
                    (this.penable  !== rhs.penable)  ||
                    (this.pwrite   !== rhs.pwrite)   ||
                    (this.psel     !== rhs.psel)     ||
                    (this.prdata   !== rhs.prdata)   ||
                    (this.pready   !== rhs.pready)   ||
                    (this.pslverr  !== rhs.pslverr)  
                  ) begin
                    return 0;
                end
                else begin
                    return 1;
                end
            end
            else begin
                `uvm_fatal("COMPARE_FAIL", "Object types do not match for comparison")
            end
        endfunction : compare



`endif