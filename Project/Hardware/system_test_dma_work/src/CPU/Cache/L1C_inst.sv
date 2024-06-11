//================================================
// Auther:      Hsin-Hang Wu (Shawn)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     1.0
//================================================
//issues: 17, 25, 213
`include "def.svh"
 `include "AXI_define.svh"
module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  // from CPU wrapper
  input [`DATA_BITS-1:0] I_out,
  input cacheD_wait, //???�???��?��????????�?調�?? (stall_IF)
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,
  // to CPU wrapper
  output logic I_req,
  output logic [`DATA_BITS-1:0] I_addr,

  input RVALID, RLAST, //??�以調�??(??��?��??�????)
  input stall_DM
);

logic [`CACHE_INDEX_BITS-1:0] index;
logic [`CACHE_DATA_BITS-1:0] DA_out;
logic [`CACHE_DATA_BITS-1:0] DA_in;
logic [`CACHE_WRITE_BITS-1:0] DA_write;
logic DA_read;
logic [`CACHE_TAG_BITS-1:0] TA_out;
logic [`CACHE_TAG_BITS-1:0] TA_in;
logic TA_write;
logic TA_read;
logic [`CACHE_LINES-1:0] valid;

logic hit;

localparam IDLE=3'd0,
            READ=3'd1,
            READ_MISS=3'd2,
            READ_BURST=3'd3,
            READ_END=3'd4;

logic [2:0] state, nstate;

logic [31:0] core_addr_reg;
logic [1:0] counter;

always_ff@(posedge clk or posedge rst)begin
  if(rst) state<=IDLE;
  else state<=nstate;
end

always_comb begin
  case(state)
  IDLE:begin
    // if(cacheD_wait)begin
    //   nstate=IDLE;
    // end
    // else begin
      if(core_req) nstate=READ;
      else nstate=IDLE;
    // end
  end
  READ:begin  
    if(valid[core_addr_reg[9:4]] && TA_out==core_addr_reg[31:10]) begin
      if(stall_DM) nstate=READ;
      else nstate=IDLE; //hit
    end
    else nstate=READ_BURST;
  end
  READ_MISS:begin
    if(RVALID) nstate=READ_BURST;
    else nstate=READ_MISS;
  end
  READ_BURST:begin
    if(RLAST & RVALID) nstate=READ_END;
    else nstate=READ_BURST;
  end
  READ_END: begin
    nstate=IDLE;
  end
  default:begin
    nstate=IDLE;
  end
  endcase
end

//output
always_comb begin
  case(state)
    IDLE:begin
      core_out=32'b0;
      core_wait=1'b1;
      I_addr=core_addr;
      I_req=1'b0;
    end
    READ:begin  
      if(valid[core_addr_reg[9:4]] && TA_out==core_addr_reg[31:10])begin
        case(core_addr_reg[3:2])
        2'd0: core_out=DA_out[31:0];
        2'd1: core_out=DA_out[63:32];
        2'd2: core_out=DA_out[95:64];
        2'd3: core_out=DA_out[127:96];
        endcase
        core_wait=1'b0;
        I_addr=32'b0;
        I_req=1'b0;
      end
      else begin
        core_out=32'b0;
        core_wait=1'b1;
        I_addr={core_addr_reg[31:4],4'b0};
        I_req=1'b1;
      end
    end
    READ_MISS:begin
      core_out=32'b0;
      core_wait=1'b1;
      I_addr={core_addr_reg[31:4],4'b0};
      I_req=1'b0;
    end
    READ_BURST:begin
      core_out=32'b0;
      core_wait=1'b1;
      // I_addr=core_addr_reg;
      // I_req=1'b0;
      I_addr={core_addr_reg[31:4],4'b0};
      I_req=1'b1;
    end
    READ_END:begin
      core_out=32'b0;
      core_wait=1'b1;
      I_addr={core_addr_reg[31:4],4'b0};
      I_req=1'b0;
    end
    default:begin
      core_out=32'b0;
      core_wait=1'b0;
      I_addr=32'b0;
      I_req=1'b1;
    end
  endcase
end

//data array and tag array
always_comb begin
  // if(rst)begin
  //   index=6'b0;
  //   //tag array
  //   TA_write=1'b0;
  //   TA_read=1'b0;
  //   TA_in=22'b0;
  //   //data array
  //   DA_write=16'b0;
  //   DA_read=1'b0;
  //   DA_in=32'b0;
  //   counter=2'b0;
  //   valid=64'b0;
  // end
  // else begin
    //if(I_wait)begin
      // index=index;
      // //tag array
      // TA_write=TA_write;
      // TA_read=TA_read;
      // TA_in=TA_in;
      // //data array
      // DA_write=DA_write;
      // DA_read=DA_read;
      // DA_in=DA_in;
      // counter=counter;
      // valid=valid;
    //end
    //else begin
      case(state)
      IDLE:begin
        index=core_addr[9:4];
        //tag array
        TA_write=1'b0;
        TA_read=1'b1;
        TA_in=22'b0;
        //data array
        DA_write=16'b0;
        DA_read=1'b1;
        DA_in=128'b0;
        // counter=2'b0;
        // valid=valid;
      end
      READ:begin  
        if(valid[core_addr_reg[9:4]] && TA_out==core_addr_reg[31:10])begin
          index=core_addr_reg[9:4];
          //tag array
          TA_write=1'b0;
          TA_read=1'b1;
          TA_in=22'b0;
          //data array
          DA_write=16'b0;
          DA_read=1'b1;
          DA_in=128'b0;
          // counter=2'b0;
          // valid=valid;
        end
        else begin
          index=core_addr_reg[9:4];
          //tag array
          TA_write=1'b1;
          TA_read=1'b1;
          TA_in=core_addr_reg[31:10];
          //data array
          DA_write=16'b0;
          DA_read=1'b0;
          DA_in=128'b0;
          // counter=2'b0;
          // valid=valid;
        end
      end
      READ_MISS:begin
        index=core_addr_reg[9:4];
        //tag array
        TA_write=1'b0;
        TA_read=1'b0;
        TA_in=22'b0;
        //data array
        DA_write=16'b0;
        DA_read=1'b0;
        DA_in=128'b0;      
        // counter=2'b0;
        // valid=valid;
      end
      READ_BURST:begin
        index=core_addr_reg[9:4];
        //tag array
        TA_write=1'b0;
        TA_read=1'b0;
        TA_in=22'b0;
        //data array
        case(counter)
          2'd0: begin
            DA_write={12'b0,4'b1111};
            DA_in={96'b0,I_out};
          end
          2'd1: begin
            DA_write={8'b0, 4'b1111, 4'b0};
            DA_in={64'b0,I_out,32'b0};
          end
          2'd2: begin
            DA_write={4'b0, 4'b1111, 8'b0};
            DA_in={32'b0,I_out,64'b0};
          end
          2'd3: begin
            DA_write={4'b1111, 12'b0};
            DA_in={I_out,96'b0};
          end
        endcase
        DA_read=1'b0;
        // DA_in=I_out;
        //??��??�????cycle??��??確�?? sol: ??�RVALID??��??
        // if(RVALID)begin
        //   if(counter==2'd3) counter=counter;
        //   else counter=counter+2'b1;          
        // end
        // else begin
        //   counter=counter;
        // end
        // valid[index]=1'b1;
      end
      READ_END:begin
        index=core_addr_reg[9:4];
        //tag array
        TA_write=1'b0;
        TA_read=1'b0;
        TA_in=22'b0;
        //data array
        DA_write=16'b0;
        DA_read=1'b0;
        DA_in=128'b0;      
        // counter=2'b0;
        // valid=valid;
      end
      default:begin
        index=6'b0;
        //tag array
        TA_write=1'b0;
        TA_read=1'b0;
        TA_in=22'b0;
        //data array
        DA_write=16'b0;
        DA_read=1'b0;
        DA_in=128'b0;
        // counter=2'b0;
        // valid=64'b0;
      end
      endcase
    //end
  // end
end

//register
always_ff@(posedge clk or posedge rst)begin
  if(rst)begin
    core_addr_reg<=32'b0;
  end
  else begin
    case(state)
    IDLE:begin
      core_addr_reg<=core_addr;
    end
    default:begin
      core_addr_reg<=core_addr_reg;
    end
    endcase
  end
end

always_ff@(posedge clk or posedge rst)begin
  if(rst)begin
    counter<=2'b0;
    valid<=64'd0;
  end
  else begin
    case(state)
    READ_BURST:begin
      if(RVALID)begin 
        if(counter==2'd3) counter<=counter;
        else counter<=counter+2'b1;          
      end
      else begin
        counter<=counter;
      end
	    valid[core_addr_reg[9:4]]<=1'b1;
    end
    default: begin
      counter<=2'b0;
      valid<=valid;
    end	
    endcase
  end
end

// assign hit=(valid[index] && TA_out==core_addr_reg[31:10])?1'b1:1'b0;
always_comb begin
  if(valid[core_addr_reg[9:4]] && TA_out==core_addr_reg[31:10]) hit=1'b1;
  else hit=1'b0;
end
data_array_wrapper DA(
  .A(index),
  .DO(DA_out),
  .DI(DA_in),
  .CK(clk),
  .WEB(~DA_write),
  .OE(DA_read),
  .CS(1'b1)
);
  
tag_array_wrapper  TA(
  .A(index),
  .DO(TA_out),
  .DI(TA_in),
  .CK(clk),
  .WEB(~TA_write),
  .OE(TA_read),
  .CS(1'b1)
);
endmodule

