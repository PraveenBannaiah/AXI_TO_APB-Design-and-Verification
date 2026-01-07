`ifndef AXI_MONITOR_BFM_SV
    `define AXI_MONITOR_BFM_SV

    interface axi_monitor_bfm(axi_if#(ADDR_WIDTH = 32, DATA_WIDTH = 32) bus);

        // Monitor AXI Write Address Channel
        task monitor_waddr_transaction(axi_transaction trans);
            while(bus.awvalid !== 1'b1 || bus.awready !== 1'b1) begin
                @(posedge bus.clk);
            end
            @(posedge bus.clk);
            trans.awaddr = bus.awaddr;
        endtask: monitor_waddr_transaction

        // Monitor AXI Write Data Channel
        task monitor_wdata_transaction(axi_transaction trans);
            while(bus.wlast !== 1'b1) begin
                @(posedge bus.clk);
                if(bus.wvalid === 1'b1 && bus.wready === 1'b1) begin
                    trans.wdata = bus.wdata;    
                end
            end
        endtask: monitor_wdata_transaction

        // Monitor AXI Read Address Channel
        task monitor_raddr_transaction(axi_transaction trans);
            while(bus.arvalid !== 1'b1 || bus.arready !== 1'b1) begin
                @(posedge bus.clk);
            end
            @(posedge bus.clk); 
            trans.araddr = bus.araddr;
        endtask: monitor_raddr_transaction

        // Monitor AXI Read Data Channel
        task monitor_rdata_transaction(axi_transaction trans);
            while(bus.rlast !== 1'b1) begin
                @(posedge bus.clk);
                if(bus.rvalid === 1'b1 && bus.rready === 1'b1) begin    
                    trans.rdata = bus.rdata;
                end
            end
        endtask: monitor_rdata_transaction

`endif