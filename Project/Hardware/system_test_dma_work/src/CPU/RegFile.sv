module RegFile (
input clk,
input rst,
input wb_en,
input [31:0] wb_data,
input [4:0] W_rd_index,
input [4:0] rs1_index,
input [4:0] rs2_index,
output logic [31:0] rs1_data_out,
output logic [31:0] rs2_data_out,
output logic [31:0] Ra
);
reg [31:0] registers [0:31];
int i;

assign Ra = registers[1];
assign rs1_data_out=registers[rs1_index];
assign rs2_data_out=registers[rs2_index];

always @(posedge clk or posedge rst) begin
    // if(wb_en) registers[rd_index]<=wb_data;
    if(rst)begin
        for (i=0; i<32;i=i+1)begin
		    registers[i]<=32'h0;	
	    end
    end
    else begin
        if (W_rd_index != 5'd0) begin
            if (wb_en) begin
                registers[W_rd_index] <= wb_data;
            end
        end
        // x0 is grounded
        else begin
            registers[W_rd_index] <= 32'd0;
        end
    end
end


endmodule
