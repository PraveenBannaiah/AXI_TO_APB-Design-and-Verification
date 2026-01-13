`ifndef APB_DRIVER_BFM
    `define APB_DRIVER_BFM

    interface apb_driver_bfm(apb_if#(ADDR_WIDTH = 32, DATA_WIDTH = 31) bus);

        property signal_stablity_check;
            @(posedge bus.pclk) disable iff (bus.presetn == 1'b0);
               (bus.penable) |-> $stable(bus.paddr)&&(bus.pwrite);
               //(bus.penable == 1b1 && bus.pwrite == 1'b1) |-> $stable(bus.pwdata);   //You cant have two implications in the same property
        endproperty

        property data_stablity_check;
            @(posedge bus.pclk) disable iff (bus.presetn == 1'b0);
               (bus.penable == 1'b1 && bus.pwrite == 1'b1) |-> $stable(bus.pwdata);
               //(bus.penable == 1b1 && bus.pwrite == 1'b1) |-> $stable(bus.pwdata);   //You cant have two implications in the same property
        endproperty

        addr_stability: assert property (signal_stablity_check)
            else `uvm_fatal("APB_DRIVER_BFM", "APB signals changed during active transaction");

        data_stability: assert property (data_stablity_check)
            else `uvm_fatal("APB_DRIVER_BFM", "APB write data changed during active write transaction");


        //Responder: Acting as an APB Slave
        task respond_to_apb_transaction(apb_transaction trans);

            //Assuimg LSB of psel correcponds to slave 0, next bit to slave 1 and so on.
            //Behaving like slave 0 for now.

            while(bus.psel != 1'b1) begin
                @(posedge bus.pclk);
            end

            @(posedge bus.pclk);

            //Once psel if high, paddr and pwrite are valid, hence sample it
            trans.paddr = bus.paddr;   
            trans.pwrite = bus.pwrite;

            if(trans.pwrite == 1'b1) begin
                //Write transaction
                
                @(posedge bus.pclk);

                if(bus.penable == 1'b0) begin
                    `uvm_fatal("APB_DRIVER_BFM", "PENABLE should be high after PSEL and PWRITE are valid")
                end

                //ASSERTION: The data must be stable until the transaction is complete


                //Drive PREADY
                bus.pready <= 1'b1;

                @(posedge bus.pclk);

                trans.pwdata = bus.pwdata;  //Could have sample earlier as well since data must be stable

                #2ns;  //Small delay to simulate slave response time

                //De-assert PREADY 

                bus.pready <= 1'b0;

                //Assertion to check if PENABLE is de-asserted in next cycle

                assert property (@(posedge bus.pclk) disable iff (bus.presetn == 1'b0);
                                         (bus.penable == 1'b0)
                                      )
                    else `uvm_fatal("APB_DRIVER_BFM", "PENABLE not de-asserted after PREADY de-assertion");

            end
            else begin
                //Read transaction

            end

        endtask: respond_to_apb_transaction
        
`endif