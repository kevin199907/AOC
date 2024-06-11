module Div (
    input clk,
    input rst,
    input stall,
    input stall_IF,
    input [4:0] opcode,
    input [2:0] func3,
    input func7_div,
    input [31:0] operand1,
    input [31:0] operand2,
    output logic [31:0] div_out,
    output logic stall_div
);
logic enable, enable2div;
assign enable=(opcode==5'b01100 && func7_div && (func3==3'b100||func3==3'b101||func3==3'b110||func3==3'b111));

logic [31:0] a, b, quotient, remainder;
logic [31:0] quotient_reg, remainder_reg;
logic done;

localparam  DIV = 3'b100,
            DIVU = 3'b101,
            REM = 3'b110,
            REMU = 3'b111;

typedef enum logic [1:0] {  
    IDLE, DIVWORK, DIVEND
} stateType;

stateType state, nstate;

always_ff@(posedge clk or posedge rst)begin
    if(rst) state<=IDLE;
    else begin
        if(/*stall_IF || */stall) state<=state;
        else state<=nstate;
    end
end
always_comb begin
    case(state)
    IDLE:begin
        if(enable) nstate=DIVWORK;
        else nstate=IDLE;
    end
    DIVWORK:begin
        if(done) nstate=DIVEND;
        else nstate=DIVWORK;
    end
    DIVEND:nstate=IDLE;
    default:begin
        nstate=IDLE;
    end
    endcase
end

always_comb begin
    case(state)
    IDLE:begin
        stall_div=1'b0;
        if(enable) enable2div=1'b1;
        else enable2div=1'b0;
    end
    DIVWORK:begin
        stall_div=1'b1;
        enable2div=1'b0;
    end
    DIVEND:begin
        stall_div=1'b0;
        enable2div=1'b0;
    end
    default:begin
        stall_div=1'b0;
        enable2div=1'b0;
    end
    endcase
end

always_comb begin
    case(func3)
    DIV:begin
        a=operand1;
        b=operand2;
        div_out=quotient_reg;
    end
    DIVU:begin
        a=operand1;
        b=operand2;
        div_out=quotient_reg;
    end
    REM:begin
        a=operand1;
        b=operand2;
        div_out=remainder_reg;
    end
    REMU:begin
        a=operand1;
        b=operand2;
        div_out=remainder_reg;
    end
    default: begin
        a=32'b0;
        b=32'b0;
        div_out=32'b0;
    end
    endcase
end

div_rill #(32) divider
(
    .clk(clk),
    .rst(rst), 
    .enable(enable2div),
    .a(a), 
    .b(b), 
    .yshang(quotient),
    .yyushu(remainder), 
    .done(done)
);

always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        quotient_reg<=32'b0;
        remainder_reg<=32'b0;
    end
    else begin
        case(state)
        DIVWORK:begin
            quotient_reg<=quotient;
            remainder_reg<=remainder;
        end
        default:begin
            quotient_reg<=quotient_reg;
            remainder_reg<=remainder_reg;
        end
        endcase
    end
end
endmodule