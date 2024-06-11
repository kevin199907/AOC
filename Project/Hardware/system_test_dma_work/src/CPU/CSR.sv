module CSR (
    input clk, rst,
    input [11:0] imm_ext,
    input [31:0] E_pc,
    input [31:0] D_pc,
    input [31:0] pc_32,
    input stall,
    input next_pc_sel,
    output logic [31:0] csr_o,
    input stall_IF,
    input wfi_signal,

    input intr_ex,      //interrupt external
    input intr_t,       //interrupt timer
    input intr_end_ex,  //interrupt end external 
    input intr_end_t,   //interrupt end timer 

    input [31:0] rs1_data,
    input [31:0] E_inst,
    output logic [31:0] pc_csr,

    output logic mie_out,
    output logic meie_out,
    output logic mtie_out
);

localparam  MSTATUS = 12'h300,
            MIE = 12'h304,
            MTVEC = 12'h305,
            MEPC = 12'h341,
            MIP = 12'h344,
            MCYCLE = 12'hb00,
            MCYCLEH = 12'hb80,
            MINSTRET = 12'hb02,
            MINSTRETH = 12'hb82;   

localparam  CSRRW = 3'b001,
            CSRRS = 3'b010,
            CSRRC = 3'b011,
            CSRRWI = 3'b101,
            CSRRSI = 3'b110,
            CSRRCI = 3'b111;


logic [63:0] cycle,instret;
logic [31:0] mstatus_reg, mtvec_reg, mepc_reg, mip_reg ,mie_reg;
logic [31:0] mstatus_out,  mepc_out, csr_mux, csr_tmp, csr_forwirte;

logic [11:0] inst_imt;
logic [2:0] f3;
logic [4:0] op,rs1_index,rd_index;
logic [31:0] uimm;
logic [4:0] rs1_delay;
logic [31:0] csr_reg;
logic wfi_signal_delay;

assign inst_imt=E_inst[31:20];
assign f3=E_inst[14:12];
assign op=E_inst[6:2];
assign rs1_index=E_inst[19:15];
assign rd_index=E_inst[11:7];

assign uimm={27'b0,rs1_index};

assign mie_out=mstatus_reg[3];
assign meie_out=mie_reg[11];
assign mtie_out=mie_reg[7];

always@(posedge clk or posedge rst)begin
    if(rst) begin
        rs1_delay<=5'b0;
        wfi_signal_delay<=1'b0;
    end
    else begin
        rs1_delay<=rs1_index;
        wfi_signal_delay<=wfi_signal;
    end
end

//Read CSR
always @(*) begin
    if(rd_index!=5'b0)begin
        // if(rs1_delay==5'b0) csr_o=32'b0;
        // else begin
            case (imm_ext)
            MSTATUS     : csr_o = mstatus_reg;
            MIE         : csr_o = mie_reg;
            MTVEC       : csr_o = 32'h0001_0000;//mtvec_reg;
            MEPC        : csr_o = mepc_reg;
            MIP         : csr_o = mip_reg;

            MINSTRETH    : csr_o = instret[63:32];
            MINSTRET     : csr_o = instret[31:0];
            MCYCLEH    : csr_o = cycle[63:32];
            MCYCLE    : csr_o = cycle[31:0];

            default: csr_o = 32'b0;
            endcase
        // end
    end
    else csr_o=32'b0;
end

//Write CSR (only mstatus_reg, mie_reg, mepc_reg)
always@(posedge clk or posedge rst)begin
    if(rst) begin
        mstatus_reg<=32'b0;
        mie_reg<=32'b0;
        mepc_reg<=32'b0;
    end
    else begin
        if(stall_IF) begin
            mstatus_reg<=mstatus_reg;
            mie_reg<=mie_reg;
            mepc_reg<=mepc_reg;
        end
        else begin
            if((op==5'b11100 && f3!=3'b000) /*&& rs1_index!=5'b0*/)begin
                // if(rs1_index==5'b0) begin
                //     mstatus_reg<=32'b0;
                //     mie_reg<=32'b0;
                //     mepc_reg<=32'b0;
                // end
                // else begin
                    case(imm_ext)
                    MSTATUS:begin
                        case(f3)
                            CSRRW: begin
                                if(rs1_index==5'b0) mstatus_reg<=32'b0;
                                else begin
                                    mstatus_reg[3]<=rs1_data[3];
                                    mstatus_reg[7]<=rs1_data[7];
                                    mstatus_reg[12:11]<=rs1_data[12:11]; 
                                end 
                            end                 
                            CSRRS: begin
                                if(rs1_index==5'b0) mstatus_reg<=32'b0;
                                else begin
                                    mstatus_reg[3]<=mstatus_reg[3]|rs1_data[3]; 
                                    mstatus_reg[7]<=mstatus_reg[7]|rs1_data[7];     
                                    mstatus_reg[12:11]<=mstatus_reg[12:11]|rs1_data[12:11];       
                                end  
                            end          
                            CSRRC: begin
                                if(rs1_index==5'b0) mstatus_reg<=32'b0;
                                else begin
                                    mstatus_reg[3]<=mstatus_reg[3]&(~rs1_data[3]);     
                                    mstatus_reg[7]<=mstatus_reg[7]&(~rs1_data[7]);     
                                    mstatus_reg[12:11]<=mstatus_reg[12:11]&(~rs1_data[12:11]);     
                                end
                            end       
                            CSRRWI: begin
                                mstatus_reg[3]<=uimm[3];
                                mstatus_reg[7]<=uimm[7];
                                mstatus_reg[12:11]<=uimm[12:11];
                            end       
                            CSRRSI: begin
                                mstatus_reg[3]<=mstatus_reg[3] | uimm[3]; 
                                mstatus_reg[7]<=mstatus_reg[7] | uimm[7]; 
                                mstatus_reg[12:11]<=mstatus_reg[12:11] | uimm[12:11]; 
                            end   
                            CSRRCI: begin
                                mstatus_reg[3]<=mstatus_reg[3] & ~uimm[3];  
                                mstatus_reg[7]<=mstatus_reg[7] & ~uimm[7];  
                                mstatus_reg[12:11]<=mstatus_reg[12:11] & ~uimm[12:11];  
                            end  
                        endcase

                    end
                    MIE:begin
                        case(f3)
                            CSRRW: begin
                                if(rs1_index==5'b0) mie_reg<=32'b0;
                                else begin
                                    mie_reg[7]<=rs1_data[7];
                                    mie_reg[11]<=rs1_data[11];     
                                end             
                            end
                            CSRRS: begin
                                if(rs1_index==5'b0) mie_reg<=32'b0;
                                else begin
                                    mie_reg[7]<=mie_reg[7]|rs1_data[7];      
                                    mie_reg[11]<=mie_reg[11]|rs1_data[11];    
                                end         
                            end
                            CSRRC: begin
                                if(rs1_index==5'b0) mie_reg<=32'b0;
                                else begin
                                    mie_reg[7]<=mie_reg[7]&(~rs1_data[7]); 
                                    mie_reg[11]<=mie_reg[11]&(~rs1_data[11]);  
                                end          
                            end
                            CSRRWI: begin
                                mie_reg[7]<=uimm[7];    
                                mie_reg[11]<=uimm[11];          
                            end
                            CSRRSI: begin
                                mie_reg[7]<=mie_reg[7] | uimm[7];    
                                mie_reg[11]<=mie_reg[11] | uimm[11];    
                            end
                            CSRRCI: begin
                                mie_reg[11]<=mie_reg[11] & ~uimm[11];    
                                mie_reg[7]<=mie_reg[7] & ~uimm[7];    
                            end
                        endcase
                    end
                    MEPC:begin
                        case(f3)
                            CSRRW: begin
                                if(rs1_index==5'b0) mepc_reg<=32'b0;
                                else mepc_reg<=rs1_data;                   
                            end
                            CSRRS: begin
                                if(rs1_index==5'b0) mepc_reg<=32'b0;
                                else mepc_reg<=mepc_reg|rs1_data;               
                            end
                            CSRRC: begin
                                if(rs1_index==5'b0) mepc_reg<=32'b0;
                                else mepc_reg<=mepc_reg&(~rs1_data);            
                            end
                            CSRRWI: begin
                                mepc_reg<=uimm;       
                            end
                            CSRRSI: begin
                                mepc_reg<=mepc_reg | uimm;    
                            end
                            CSRRCI: begin
                                mepc_reg<=mepc_reg & ~uimm;    
                            end
                        endcase
                    end
                    default: ;
                    endcase
                // end
            end
            else begin
                if(intr_ex || intr_t)begin
                    mstatus_reg[7]<=mstatus_reg[3];//MIE
                    mstatus_reg[3]<=1'b0;//MPIE
                    mstatus_reg[12:11]<=2'b11;//MPP
                    // mie_reg<={20'b0,intr_ex,3'b0,intr_t,7'b0};
                    if(~wfi_signal_delay) mepc_reg<=E_pc; //if WFI is currently executed, store the following instruction(not deal yet)
                    else mepc_reg<=pc_32-32'd4;
                end
                else if(intr_end_ex || intr_end_t)begin
                    mstatus_reg[7]<=1'b1;
                    mstatus_reg[3]<=mstatus_reg[7];
                    mstatus_reg[12:11]<=2'b11;
                    // mie_reg<={20'b0,intr_end_ex,3'b0,intr_end_t,7'b0};
                    mepc_reg<=32'b0;
                end
                else begin
                    mstatus_reg<=mstatus_reg;
                    // mie_reg<=mie_reg;
                    mepc_reg<=mepc_reg;
                end
            end
        end
    end
end

assign mtvec_reg=32'h0000_0288;
// assign mtvec_reg=32'h0001_002c;
assign mip_reg = {20'b0, intr_ex, 3'b0, intr_t, 7'b0};

//pc switch
always@(*)begin
    if(intr_ex || intr_t) pc_csr=mtvec_reg;
    else if(intr_end_ex || intr_end_t) pc_csr=mepc_reg;
    else pc_csr=32'hffffffff;
end


//cycle
always @(posedge clk or posedge rst ) begin
    if (rst) cycle<=64'b0;
    else cycle<=cycle+64'b1;
end

//inst
always @(posedge clk or posedge rst ) begin
    if (rst) begin
        instret<=64'b1;
    end
    else begin;
	if(E_pc!=32'b0 && ~stall_IF)instret<=instret+64'b1;
    // if(stall==1'b0 && next_pc_sel==1'b0)instret<=instret+64'b1;
    end
end

endmodule
