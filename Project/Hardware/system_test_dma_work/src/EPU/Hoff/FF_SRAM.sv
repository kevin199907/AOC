
////////////////////////////////  FF_SRAM  ////////////////////////////////////////////////////
module FF_SRAM (
    input clk,
	input rst,
	input valid,
	input last,
    input [31:0] data,
    output logic done,
	output logic[31:0] TO_SRAM_DATA,
	output logic[11:0] sram_addr,
	output logic[3:0] WE,
	output logic last_to_cpu
);
parameter IDLE = 2'd0;
parameter PRO =  2'd1;
parameter SRAM = 2'd2;
parameter LAST_0 = 2'd3;

logic last_reg;
logic [1:0] state;
logic [1:0] nstate;
assign done = (state != 2'b00)&&(nstate == 2'b00);
//
logic [31:0] data_reg;
logic [7:0] temp [7:0];
logic [1:0] valid_tag;
logic [2:0] index;
logic [1:0] counter;
logic [2:0] save_counter;
//
logic [7:0] FF_temp;
logic FF_detect;
assign FF_detect = (FF_temp==8'hff)?1'b1:1'b0;
//

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        last_reg <= 1'b0;
    end 
    else begin
		if(valid)	last_reg <= last;
		else		last_reg <= last_reg;
    end
end
always_comb begin ////////// comb output logic
    case(state)
        IDLE: begin
            TO_SRAM_DATA = 32'b0;
			WE = 4'b1111;//
			last_to_cpu = 1'b0;
        end

        PRO: begin
            TO_SRAM_DATA = 32'b0;
			WE = 4'b1111;//
			last_to_cpu = 1'b0;
        end

        SRAM: begin
			WE = 4'b0;
			last_to_cpu = 1'b0;
			if(index>=3'd4) TO_SRAM_DATA = {temp[0],temp[1],temp[2],temp[3]};
			else TO_SRAM_DATA = {temp[4],temp[5],temp[6],temp[7]};
        end
		LAST_0: begin
			last_to_cpu = 1'b1;
			if(index>=3'd4) begin
				case(save_counter)
					3'd0: begin
						TO_SRAM_DATA = 32'b0;
						WE = 4'b1111;//
					end

					3'd1: begin
						TO_SRAM_DATA = {temp[4],24'b0};
						WE = 4'b0;
					end

					3'd2: begin
						TO_SRAM_DATA = {temp[4],temp[5],16'b0};
						WE = 4'b0;
					end
					3'd3: begin
						TO_SRAM_DATA = {temp[4],temp[5],temp[6],8'b0};
						WE = 4'b0;
					end
					default : begin
						TO_SRAM_DATA = 32'b0;
						WE = 4'b1111;//
					end
				endcase
			end
			else begin
				case(save_counter)
					3'd0: begin
						TO_SRAM_DATA = 32'b0;
						WE = 4'b1111;//
					end

					3'd1: begin
						TO_SRAM_DATA = {temp[0],24'b0};
						WE = 4'b0;
					end

					3'd2: begin
						TO_SRAM_DATA = {temp[0],temp[1],16'b0};
						WE = 4'b0;
					end
					3'd3: begin
						TO_SRAM_DATA = {temp[0],temp[1],temp[2],8'b0};
						WE = 4'b0;
					end
					default : begin
						TO_SRAM_DATA = 32'b0;
						WE = 4'b1111;//
					end
				endcase			
			end
        end
    endcase
end
always_ff @( posedge clk or posedge rst) begin
    if(rst) begin
        sram_addr <= 12'b0;
    end
    else begin
		case(state)
			IDLE: begin
				sram_addr <= sram_addr;
			end

			PRO: begin
				sram_addr <= sram_addr;
			end

			SRAM: begin
				sram_addr <= sram_addr + 12'd1;
			end
			LAST_0: begin
				if(WE == 4'b1111) 	sram_addr <= sram_addr;//
				else			sram_addr <= sram_addr + 12'd1;
			end
		endcase
    end
end
always_comb begin ///// 
    case(counter)
        2'b00: begin
            FF_temp = data_reg[31:24];
        end
        2'b01: begin
            FF_temp = data_reg[23:16];
        end
        2'b10: begin
			FF_temp = data_reg[15:8];
        end
		2'b11: begin
			FF_temp = data_reg[7:0];
        end
    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= IDLE;
    end 
    else begin
        state <= nstate;
    end
end

always_comb begin ///// nstate logic
    case(state)
        IDLE: begin
            if(valid) begin
				nstate = PRO;
            end
            else begin
                nstate = IDLE;
            end
        end

        PRO: begin
            if(((save_counter ==3'd2)&&FF_detect)||(save_counter==3'd3))	nstate = SRAM;
			else if(counter == 2'd3) begin // we have collected all the data from previous module , if(last_reg) -> LAST_0 , else -> IDLE
				if(last_reg)	nstate = LAST_0;
				else 			nstate = IDLE;
			end
			else nstate = PRO;
        end

        SRAM: begin
			if(counter != 2'b00)	nstate = PRO;
			else begin 
				if(last_reg)	nstate = LAST_0;
				else 			nstate = IDLE;
			end
        end
		LAST_0: begin
			nstate = IDLE;
        end
    endcase
end



integer i;
always_ff @( posedge clk or posedge rst) begin
    if(rst) begin
		for(i = 0; i < 8; i++)begin
            temp[i] <= 8'b0;
        end
    end
    else begin
		case(state)
			IDLE: begin
				temp <= temp;
			end
			PRO: begin
				if(FF_detect)begin
					case(index)
						3'd0: begin
							temp[0] <= FF_temp;
							temp[1] <= 8'h00;
						end
						3'd1: begin
							temp[1] <= FF_temp;
							temp[2] <= 8'h00;
						end
						3'd2: begin
							temp[2] <= FF_temp;
							temp[3] <= 8'h00;
						end
						3'd3: begin
							temp[3] <= FF_temp;
							temp[4] <= 8'h00;
						end
						3'd4: begin
							temp[4] <= FF_temp;
							temp[5] <= 8'h00;
						end
						3'd5: begin
							temp[5] <= FF_temp;
							temp[6] <= 8'h00;
						end
						3'd6: begin
							temp[6] <= FF_temp;
							temp[7] <= 8'h00;
						end
						3'd7: begin
							temp[7] <= FF_temp;
							temp[0] <= 8'h00;
						end
					endcase
					// if(index == 3'd7)	begin
					// temp[index] <= FF_temp;
					// temp[0] <= 8'h00;
					// end
					// else if(index < 3'd7)	begin
					// temp[index] <= FF_temp;
					// temp[index+1] <= 8'h00;
					// end
				end
				else	temp[index] <= FF_temp;
			end
			SRAM: begin
				temp <= temp;
			end
			LAST_0: begin
				temp <= temp;
			end
		endcase
    end
end

// ???
always_ff @( posedge clk or posedge rst) begin
    if(rst) begin
        data_reg <= 32'b0;
    end
    else begin
		case(state)
			IDLE: begin
				if(valid) data_reg <= data;
				else data_reg <= data_reg;
			end

			PRO: begin
				data_reg<=data_reg;
			end

			SRAM: begin
				data_reg<=data_reg;
			end
			LAST_0: begin
				data_reg<=data_reg;
			end
		endcase
    end
end
// FF_detect
// counter logic
always_ff @( posedge clk or posedge rst) begin 
    if(rst) begin
        counter <= 2'b0;
    end
	else begin
		case(state)
			IDLE: begin
				counter <= 2'b0;
			end

			PRO: begin
				counter <= counter + 2'b1;
			end

			SRAM: begin
				counter <= counter;
			end
			LAST_0: begin
				counter <= counter;
			end
		endcase
	end
end

// index logic
always_ff @( posedge clk or posedge rst) begin 
    if(rst) begin
        index <= 3'b0;
		save_counter <= 3'b0;
    end
	else begin
		case(state)
			IDLE: begin
				index <= index;
				save_counter <= save_counter;//3'b0;
			end

			PRO: begin
				if(FF_detect)	begin
				index <= index + 3'd2;
				save_counter <= save_counter+3'd2;
				end
				else 	begin
				index <= index + 3'd1;
				save_counter <= save_counter+3'd1;
				end
			end

			SRAM: begin
				index <= index;
				save_counter <= save_counter-3'd4;//3'b0;
			end
			LAST_0: begin
				index <= index;
				save_counter <= save_counter-3'd4;//3'b0;
			end
		endcase
	end
end

endmodule
