`ifndef AXI_TRANSACTION_SVH
    `define AXI_TRANSACTION_SVH
    
    class axi_transaction extends uvm_sequence_item;

        //Maybe split into separate classes for read and write channels
        //but how to handle transaction IDs then?


        // AXI Write Address Channel
        rand bit [31:0] awaddr;
        rand bit [2:0] awprot;
        rand bit [3:0] aw_transaction_id;    

        // AXI Write Data Channel
        rand bit [31:0] wdata;
        rand bit [3:0] wstrb;
        rand bit wlast;
        rand bit [3:0] w_transaction_id;

        //AXI Read Address Channel
        rand bit [31:0] araddr;
        rand bit [2:0] arprot;
        rand bit [3:0] ar_transaction_id;

        
        `uvm_object_utils(axi_transaction)   //Register with the factory

        function new(string name = "");
            super.new(name);
        endfunction : new

        virtual function string convert2string();
            return $sformatf("AWADDR: %h, AWPROT: %b, AWID: %0d, WDATA: %h, WSTRB: %b, WLAST: %b, WID: %0d, ARADDR: %h, ARPROT: %b, ARID: %0d",
                             awaddr, awprot, aw_transaction_id,
                             wdata, wstrb, wlast, w_transaction_id,
                             araddr, arprot, ar_transaction_id);
        endfunction : convert2string


        virtual function bit compare(uvm_object rhs);

            if($cast(this,rhs)) begin
                if( (this.awaddr               !== rhs.awaddr)               ||
                    (this.awprot               !== rhs.awprot)               ||
                    (this.aw_transaction_id    !== rhs.aw_transaction_id)    ||
                    (this.wdata                !== rhs.wdata)                ||
                    (this.wstrb                !== rhs.wstrb)                ||
                    (this.wlast                !== rhs.wlast)                ||
                    (this.w_transaction_id     !== rhs.w_transaction_id)     ||
                    (this.araddr               !== rhs.araddr)               ||
                    (this.arprot               !== rhs.arprot)               ||
                    (this.ar_transaction_id    !== rhs.ar_transaction_id)    
                  ) begin
                    return 0;
                end
                else begin
                    return 1;
                end
            end
            else begin
                `uvm_fatal("COMPARE", "Object type mismatch in compare")
            end
        endfunction: compare


    endclass: axi_transaction


`endif