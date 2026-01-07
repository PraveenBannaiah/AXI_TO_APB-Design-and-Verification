`ifndef AXI_DRIVER_BFM_SV
    `define AXI_DRIVER_BFM_SV

    interface axi_driver_bfm (axi_if#(ADDR_WIDTH = 32, DATA_WIDTH = 32) bus);

        task drive_waddr_transaction(axi_transaction trans);   
            // Drive AXI Write Address Channel
            if(trans.awaddr !== 'x) begin
                @(posedge bus.clk);
                bus.awaddr <= trans.awaddr;
                bus.awvalid <= 1'b1;

            while(bus.awready !== 1'b1) begin
                @(posedge bus.clk);
            end

            @(posedge bus.clk);
            bus.awvalid <= 1'b0;
            end

        endtask: drive_waddr_transaction

        task drive_wdata_transaction(axi_transaction trans);

            //FIXME: Add suport for writing multiple data beats using wstrb and wlast

            // Drive AXI Write Data Channel
            if(bus.wready !== 1'b1) begin
                @(posedge bus.clk);
                bus.wdata <= trans.wdata;
                bus.valid <= 1'b1;

                bus.wlast <= trans.wlast;

                @(posedge bus.clk);
                bus.wvalid <= 1'b0;
                bus.wlast <= 1'b0;
            end

            else begin
                while(bus.wready !== 1'b1) begin
                    @(posedge bus.clk);
                end

                (posedge bus.clk);
                bus.wdata <= trans.wdata;
                bus.valid <= 1'b1;

                bus.wlast <= trans.wlast;

                @(posedge bus.clk);
                bus.wvalid <= 1'b0;
                bus.wlast <= 1'b0;
            end

            

        endtask: drive_wdata_transaction

        task drive_raddr_transaction(axi_transaction trans):
            // Drive AXI Read Address Channel
            if(trans.araddr != 'x) begin
                @(posedge bus.clk);
                bus.araddr <= trans.araddr;
                bus.arvalid <= 1'b1;
                while(bus.arread !== 1'b1) begin
                    @(posedge bus.clk);
                end
                @(posedge bus.clk);
                bus.arvalid <= 1'b0;
            end
        endtask: drive_raddr_transaction

        task drive_rdata_transaction(axi_transaction trans);
            // Drive AXI Read Data Channel
            
            //Write an assertion to check if arready is high before reading data

            while(bus.rlast !==1'b1) begin
                @(posedge bus.clk);

                if(bus.rvalid === 1'b1) begin
                    //Capture read data
                    $display("Read Data: %h", bus.rdata);
                    //Add more logic here to store or process read data as needed
                end
            end

            //Capture the last data beat
            if(bus.rvalid === 1'b1) begin
                $display("Read Data (Last Beat): %h", bus.rdata);
            end

        endtask: drive_rdata_transaction


    endinterface : axi_driver_bfm

`endif