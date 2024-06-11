module INTR_CONTROLLER(
    input clk,
    input rst,
    input [31:0] inst,

    input interrupt_e, //from sensor
    input interrupt_t, //from timer

    // input wfi,
    // input mret,

    input mie,
    input meie,
    input mtie,

    // input stall,
    
    //To csr
    output logic intr_ex, //interrupt begin
    output logic intr_t,
    output logic intr_end_ex, //interrupt end
    output logic intr_end_t, //it won't be used because pc won't return
    //To cpu(like pc, pipeline register...)
    output logic wfi_signal,

    input stall_IF
    
);
localparam  MRET_INST=32'b00110000001000000000000001110011,
            WFI_INST= 32'b00010000010100000000000001110011;

localparam NORMAL=2'd0,
            WFI=2'd1,
            TRAP=2'd2,
            TIMEOUT=2'd3;
logic [1:0] state, nstate;

always@(posedge clk or posedge rst)begin
    if(rst) state<=NORMAL;
    else state<=nstate;
end


always@(*)begin
    case(state)
    NORMAL: begin
        if(~stall_IF)begin
            if(interrupt_t && mtie && mie) nstate=TIMEOUT;
            else if(interrupt_e && meie && mie) nstate=TRAP;
            else if(inst==WFI_INST) nstate=WFI;
            else nstate=NORMAL;
        end
        else nstate=NORMAL;
    end
    WFI: begin
        if(~stall_IF)begin
            if(interrupt_t && mtie && mie) nstate=TIMEOUT;
            else if(interrupt_e && meie && mie) nstate=TRAP;
            else nstate=WFI;
        end
        else nstate=WFI;
    end
    TRAP: begin
        if(~stall_IF)begin
            if(inst==MRET_INST) nstate=NORMAL;
            else nstate=TRAP;
        end
        else nstate=TRAP;
    end
    TIMEOUT: begin
        if(~stall_IF)begin
            if (~interrupt_t) nstate=NORMAL;
            else nstate=TIMEOUT;
        end
        else nstate=TIMEOUT;
    end
    endcase
end

//To CSR
always@(*)begin
    case(state)
    NORMAL:begin
        //intr begin
        if(nstate==TRAP) begin
            intr_ex=1'b1;
            intr_t=1'b0;
        end
        else if (nstate==TIMEOUT) begin
            intr_ex=1'b0;
            intr_t=1'b1;
        end
        else begin
            intr_ex=1'b0;
            intr_t=1'b0;
        end
        //intr end
        intr_end_ex=1'b0;
        intr_end_t=1'b0;
        //wfi
        if(nstate==WFI) wfi_signal=1'b1;
        else wfi_signal=1'b0;
    end
    WFI:begin
        //intr begin
        if(nstate==TRAP) begin
            intr_ex=1'b1;
            intr_t=1'b0;
        end
        else if(nstate==TIMEOUT) begin
            intr_ex=1'b0;
            intr_t=1'b1;
        end
        else begin
            intr_ex=1'b0;
            intr_t=1'b0;
        end
        //intr end
        intr_end_ex=1'b0;
        intr_end_t=1'b0;
        
        //wfi
        if(nstate==TRAP) wfi_signal=1'b0;
        else wfi_signal=1'b1;
    end
    TRAP:begin
        //intr begin
        if(nstate==NORMAL) intr_end_ex=1'b1;
        else intr_end_ex=1'b0;
        //intr end
        intr_ex=1'b0;
        intr_t=1'b0;
        intr_end_t=1'b0;
        //wfi
        wfi_signal=1'b0;
    end
    TIMEOUT:begin
        if(nstate==NORMAL) intr_end_t=1'b1;
        else intr_end_t=1'b0;

        intr_ex=1'b0;
        intr_end_ex=1'b0;
        intr_t=1'b0;

        wfi_signal=1'b0;
    end
    endcase
end


endmodule
