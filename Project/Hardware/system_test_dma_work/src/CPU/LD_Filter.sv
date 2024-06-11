module LD_Filter (
input [2:0] func3,
input [31:0] ld_data,
output reg [31:0] ld_data_f,
input [1:0] W_lasttwo
);
//å¸¸æ?¸é?¨å????? sign-extended 12-bitï¼?è¼???¥ä??????????? rs1??«å????¨å??ä¸? sign-extended 12-bitï¼?
//LW??ºè????? 32-bitè³????å¯«å?? rd??«å????¨ï??LH/LHU??ºè????? 16-bitè³?????????¥å?? unsigned/signed extension??? 32-bitå¾?å¯«å?? rd??«å????¨ï??
//LB/LBU??ºè????? 8-bitè³?????????¥å?? unsigned/signed extension??? 32-bitå¾?å¯«å?? rd??«å?????


always @(*) begin
    case(W_lasttwo)
    2'b01:begin
        case(func3)
            //LW
            // 3'b010: ld_data_f={{8{ld_data[31]}},ld_data[31:7]};
            3'b010: ld_data_f=ld_data;
            //LH
            3'b001: ld_data_f={{16{ld_data[23]}},ld_data[23:8]};//
            //LB
            3'b000: ld_data_f={{24{ld_data[15]}},ld_data[15:8]};
            //LHU
            3'b101: ld_data_f={16'b0,ld_data[23:8]};
            //LBU
            // 3'b100: ld_data_f={24'b0,ld_data[15:7]};
            3'b100: ld_data_f={24'b0,ld_data[15:8]};
            default: ld_data_f=32'b0;
        endcase        
    end
    2'b10:begin
        case(func3)
            //LW
            // 3'b010: ld_data_f={{16{ld_data[31]}},ld_data[31:16]};
            3'b010: ld_data_f=ld_data;
            //LH
            3'b001: ld_data_f={{16{ld_data[31]}},ld_data[31:16]};//
            //LB
            3'b000: ld_data_f={{24{ld_data[23]}},ld_data[23:16]};
            //LHU
            3'b101: ld_data_f={16'b0,ld_data[31:16]};
            //LBU
            3'b100: ld_data_f={24'b0,ld_data[23:16]};
            default: ld_data_f=32'b0;
        endcase
    end
    2'b11:begin
        case(func3)
            //LW
            // 3'b010: ld_data_f={{24{ld_data[31]}},ld_data[31:24]};
            3'b010: ld_data_f=ld_data;
            //LH
            3'b001: ld_data_f={{24{ld_data[31]}},ld_data[31:24]};
            //LB
            3'b000: ld_data_f={{24{ld_data[31]}},ld_data[31:24]};
            //LHU
            3'b101: ld_data_f={24'b0,ld_data[31:24]};
            //LBU
            3'b100: ld_data_f={24'b0,ld_data[31:24]};
            default: ld_data_f=32'b0;
        endcase
    end
    default:begin
        case(func3)
            //LW
            3'b010: ld_data_f=ld_data;
            //LH
            3'b001: ld_data_f={{16{ld_data[15]}},ld_data[15:0]};
            //LB
            3'b000: ld_data_f={{24{ld_data[7]}},ld_data[7:0]};
            //LHU
            3'b101: ld_data_f={16'b0,ld_data[15:0]};
            //LBU
            3'b100: ld_data_f={24'b0,ld_data[7:0]};
            default: ld_data_f=32'b0;
        endcase
    end
    endcase
end

endmodule