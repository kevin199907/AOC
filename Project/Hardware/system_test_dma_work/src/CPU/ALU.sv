module ALU (
input [4:0] opcode,
input [2:0] func3,
input func7,
input [31:0] operand1,
input [31:0] operand2,
output logic [31:0] alu_out
);
//computation Instruction
//Register – Register    add, sub, slt, sltu, sll, srl, sra, xor, or, and
//Register – Immediate   addi, slti, sltiu, slli, srli, srai, xori, ori, andi
//Long Immediate         lui, auipc
// +: add, addi
// -: sub,slt,sltu, slti sltiu
// shift: sll, srl, sra, slli, srli, srai
// logic: xor, or, and, xori, ori, andi

//load and store instruction
//load  lb, lh, lw, lbu, lhu
//store sb, sh, sw

//Control Transfer Instruction
//unconditional jump    jal, jalr
//conditional branch    beq, bne, blt, bge, bltu, bgeu
always @(*) begin
    case(opcode)
    5'b01100, 5'b00100:begin
        case(func3)
            3'b000:begin
                if(opcode==5'b00100) alu_out=operand1+operand2; //addi
                else begin
                    if(func7) alu_out=operand1-operand2;   //-
                    else alu_out=operand1+operand2;        //+
                end
            end

            3'b010: alu_out=($signed(operand1)<$signed(operand2))?1:0; //slt, slti
            3'b011: alu_out=(operand1<operand2)?1:0; //sltu, sltiu

            3'b001: alu_out=operand1<<(operand2 & 32'b11111); //sll slli
            3'b101:begin
                if(func7) /*alu_out=operand1>>>operand2[4:0];*/alu_out=$signed(operand1)>>>(operand2 & 32'b11111); //sra srai
                else /*alu_out=operand1>>operand2[4:0];*/alu_out=operand1>>(operand2 & 32'b11111); //srl srli
            end
            3'b110: alu_out=operand1|operand2;//or,ori
            3'b100: alu_out=operand1^operand2;//xor,xori
            3'b111: alu_out=operand1&operand2;//and, andi
            // default: alu_out=32'b0;
        endcase
    end
    5'b01101: alu_out=operand2;//lui
    5'b00101: alu_out=operand1+operand2;//auipc

    //load and store
    5'b00000, 5'b01000: begin
        alu_out=operand1+operand2;
    end

    5'b11011, 5'b11001: alu_out=operand1+32'd4; //jal jalr
    5'b11000: begin//branch
        case(func3)
            //beq
            3'b000: alu_out=(operand1==operand2)?1:0;
            //bne
            3'b001: alu_out=~(operand1==operand2)?1:0;
            //blt
            3'b100: alu_out=($signed(operand1)<$signed(operand2))?1:0;
            //bge
            3'b101: alu_out=~($signed(operand1)<$signed(operand2))?1:0;
            //bltu
            3'b110: alu_out=(operand1<operand2)?1:0;
            //bgeu
            3'b111: alu_out=~(operand1<operand2)?1:0;
            default: alu_out=32'b0;
        endcase
    end
    default: alu_out=32'b0;
    endcase

end


endmodule
