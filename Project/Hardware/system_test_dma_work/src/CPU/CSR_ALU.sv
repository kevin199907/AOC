module CSR_ALU (
    input [31:0] csr,
    input [31:0] rs1_data,
    input [2:0] f3,
    output logic [31:0] csr_out
);
localparam  CSRRW = 3'b001,
            CSRRS = 3'b010,
            CSRRC = 3'b011,
            CSRRWI = 3'b100,
            CSRRSI = 3'b110,
            CSRRCI = 3'b111;

always@(*)begin
    case(f3)
    CSRRW: csr_out=rs1_data;                   
    CSRRS: csr_out=csr|rs1_data;               
    CSRRC: csr_out=csr&(~rs1_data);            
    CSRRWI: csr_out={27'b0,rs1_data[19:15]};       
    CSRRSI: csr_out=csr | {27'b0,rs1_data[19:15]};    
    CSRRCI: csr_out=csr & ~{27'b0,rs1_data[19:15]};    
    endcase
end

endmodule