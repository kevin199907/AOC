//================================================
// Auther:      Hsin-Hang Wu (Shawn)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     2.0
//================================================
`include "def.svh"
 `include "AXI_define.svh"

module L1C_data(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // CPU wrapper to Mem
  output logic D_req,
  output logic [`DATA_BITS-1:0] D_addr,
  output logic D_write,
  output logic [`DATA_BITS-1:0] D_in,
  output logic [`CACHE_TYPE_BITS-1:0] D_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] D_out,
  input cacheI_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
  output logic core_wait,

  input BREADY, BVALID, RLAST, RVALID,
  output logic hit_data
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

localparam  IDLE=3'd0,
            READ=3'd1,
            PASS_READ=3'd2,
            READ_BURST=3'd3,
            READ_END=3'd4,
            WRITE=3'd5,
            WRITE_END=3'd6,
            PASS_WRITE=3'd7;

logic [2:0] state, nstate, pstate;

logic [31:0] core_addr_reg, core_in_reg, core_addr_justforcheck;
logic [1:0] counter;
logic [2:0] core_type_reg;
logic core_req_reg, core_write_reg, hit;
logic [21:0] TA_out_reg;
logic [31:0] core_addr_justforcheck_mux;

// logic [5:0] index_true, index_reg_true;
// logic [31:0] tag_out_true, tag_out_reg_true;
// assign index_true=core_addr[9:4];
// assign index_reg_true=core_addr_reg[9:4];
// assign tag_out_true=core_addr[31:10];
// assign tag_out_reg_true=core_addr_reg[31:10];

logic cacheable;
always_comb cacheable = (core_addr[31:16]!=16'h1000 & core_addr[31:16]!=16'h6000);
// always_comb cacheable = 1'b1;

always_ff@(posedge clk or posedge rst)begin
  if(rst) state<=IDLE;
  else state<=nstate;
end

always_comb begin
  case(state)
  IDLE:begin
    if(cacheable)begin
      if(cacheI_wait)begin
        nstate=IDLE;
      end
      else begin
        if(core_req) begin
          if(core_write) nstate=WRITE;
          else nstate=READ;
        end
        else nstate=IDLE;
      end
    end
    else begin
      if(core_req) begin
        if(core_write) nstate=PASS_WRITE;
        else nstate=PASS_READ;
      end
      else nstate=IDLE;
    end
  end
  READ:begin  
    if(valid[core_addr_reg[9:4]] && TA_out==core_addr_reg[31:10]) nstate=IDLE; //hit
    else nstate=READ_BURST;
  end
  READ_BURST:begin
    if(RLAST & RVALID) nstate=READ_END;
    else nstate=READ_BURST;
  end
  READ_END: begin
    nstate=READ;
  end
  WRITE:begin
    if(BVALID && BREADY) nstate=WRITE_END;
    else nstate=WRITE;    
  end
  WRITE_END: nstate=IDLE;
  PASS_READ: begin
    if(RLAST & RVALID) nstate=IDLE;
    else nstate=PASS_READ;
  end
  PASS_WRITE: begin
    if(BVALID && BREADY) nstate=IDLE;
    else nstate=PASS_WRITE;
  end
  endcase
end

//output
always_comb begin
  case(state)
    IDLE:begin
      if(cacheable)begin
        if(core_req) begin
          if(pstate==WRITE_END) core_wait=1'b0;
          else core_wait=1'b1;
        end
        else core_wait=1'b0;
        core_out=32'b0;

        D_req=1'b0;
        D_addr=core_addr;

        D_write=1'b0;
        D_in=32'b0;
        D_type=3'b0;
      end
      else begin
        if(core_req) begin
          if(pstate==PASS_WRITE)  core_wait=1'b0;
          else core_wait=1'b1;
        end
	  else core_wait=1'b0;

        core_out=32'b0;
        D_addr=core_addr;
        D_req=1'b0;

        D_write=1'b0;
        D_in=32'b0;
        D_type=3'b0;      
      end
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
        D_addr=32'b0;
        D_req=1'b0;
      end
      else begin
        core_out=32'b0;
        core_wait=1'b1;
        D_addr={core_addr_reg[31:4],4'b0};
        D_req=1'b1;
      end
      D_write=1'b0;
      D_in=32'b0;
      D_type=3'b0;
    end
    READ_BURST:begin
      core_out=32'b0;
      core_wait=1'b1;
      D_addr={core_addr_reg[31:4],4'b0};
      D_req=1'b1;

      D_write=1'b0;
      D_in=32'b0;
      D_type=3'b0;
    end
    READ_END:begin
      core_out=32'b0;
      core_wait=1'b1;
      D_addr={core_addr_reg[31:4],4'b0};
      D_req=1'b0;

      D_write=1'b0;
      D_in=32'b0;
      D_type=3'b0;
    end
    WRITE:begin
      core_out=32'b0;
      core_wait=1'b1;
      D_addr=core_addr_reg;
      D_req=1'b0;   

      D_write=1'b1;
      D_in=core_in_reg;
      D_type=core_type_reg;
    end
    WRITE_END:begin
      core_out=32'b0;
      core_wait=1'b1;
      D_addr=32'b0;
      D_req=1'b0;   

      D_write=1'b0;
      D_in=32'b0;
      D_type=3'b0;
    end
    PASS_READ:begin
      if(RLAST & RVALID)begin
        core_out=D_out;
        core_wait=1'b0;
        D_addr=core_addr_reg;
        D_req=1'b0;   

        D_write=1'b0;
        D_in=32'b0;
        D_type=3'b0;
      end
      else begin
        core_out=32'b0;
        core_wait=1'b1;
        D_addr=core_addr_reg;
        D_req=1'b1;   

        D_write=1'b0;
        D_in=32'b0;
        D_type=3'b0;
      end
    end
    PASS_WRITE:begin
      if(BVALID && BREADY)begin
        core_out=32'b0;
        core_wait=1'b0;
        D_addr=core_addr_reg;
        D_req=1'b0;   

        D_write=1'b0;
        D_in=core_in_reg;
        D_type=3'b0;
      end
      else begin
        core_out=32'b0;
        core_wait=1'b1;
        D_addr=core_addr_reg;
        D_req=1'b0;   

        D_write=1'b1;
        D_in=core_in_reg;
        D_type=3'b0;
      end
    end
    
  endcase
end

//data array and tag array
always_comb begin
  case(state)
  IDLE:begin
    if(cacheable)begin
      index=core_addr[9:4];
      //tag array
      TA_write=1'b0;
      TA_read=1'b1;
      TA_in=22'b0;
      //data array
      DA_write=16'b0;
      DA_read=1'b0;
      DA_in=128'b0;
      // valid=valid;
    end
    else begin
      index=core_addr_reg[9:4];
      //tag array
      TA_write=1'b0;
      TA_read=1'b1;
      TA_in=22'b0;
      //data array
      DA_write=16'b0;
      DA_read=1'b0;
      DA_in=128'b0;

      // valid=valid;
    end
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
      DA_read=1'b1;
      DA_in=128'b0;
      // valid=valid;
    end
  end
  READ_BURST:begin
    index=core_addr_reg[9:4];
    //tag array
    TA_write=1'b0;
    TA_read=1'b1;
    TA_in=22'b0;
    //data array
    case(counter)
      2'd0: begin
        DA_write={12'b0,4'b1111};
        DA_in={96'b0,D_out};
      end
      2'd1: begin
        DA_write={8'b0, 4'b1111, 4'b0};
        DA_in={64'b0,D_out,32'b0};
      end
      2'd2: begin
        DA_write={4'b0, 4'b1111, 8'b0};
        DA_in={32'b0,D_out,64'b0};
      end
      2'd3: begin
        DA_write={4'b1111, 12'b0};
        DA_in={D_out,96'b0};
      end
    endcase
    DA_read=1'b1;
    // valid[index]=1'b1;
  end
  READ_END:begin
    index=core_addr_reg[9:4];
    //tag array
    TA_write=1'b0;
    TA_read=1'b1;
    TA_in=22'b0;
    //data array
    DA_write=16'b0;
    DA_read=1'b1;
    DA_in=128'b0;      

    // valid=valid;
  end
  WRITE:begin
    index=core_addr_reg[9:4];
    //tag array
    TA_write=1'b0;
    TA_read=1'b1;
    TA_in=22'b0;
    //data array
    DA_read=1'b1;
    if(valid[core_addr_reg[9:4]] && TA_out_reg==core_addr_reg[31:10]) begin
      case(core_addr_reg[3:2])
      2'd0: DA_in={96'b0,core_in_reg};
      2'd1: DA_in={64'b0,core_in_reg,32'b0};
      2'd2: DA_in={32'b0,core_in_reg,64'b0};
      2'd3: DA_in={core_in_reg,96'b0};
      endcase
      // DA_in=core_in_reg;
      case(core_type_reg)
        // `CACHE_BYTE, `CACHE_BYTE_U:begin
        //   case(core_addr_reg[3:2])
        //   2'b00: DA_write={15'b0, 1'b1};
        //   2'b01: DA_write={11'b0, 1'b1, 4'b0};
        //   2'b10: DA_write={7'b0, 1'b1, 8'b0};
        //   2'b11: DA_write={3'b0, 1'b1, 12'b0};
        //   endcase
        // end
        // `CACHE_HWORD, `CACHE_HWORD_U:begin
        //   case(core_addr_reg[3:2])
        //   2'b00: DA_write={14'b0, 2'b11};
        //   2'b01: DA_write={10'b0, 2'b11, 4'b0};
        //   2'b10: DA_write={6'b0, 2'b11, 8'b0};
        //   2'b11: DA_write={2'b0, 2'b11, 12'b0};
        //   endcase
        // end
        `CACHE_WORD, `CACHE_HWORD, `CACHE_HWORD_U, `CACHE_BYTE, `CACHE_BYTE_U:begin
          case(core_addr_reg[3:2])
          2'b00: DA_write={12'b0, 4'b1111};
          2'b01: DA_write={8'b0, 4'b1111, 4'b0};
          2'b10: DA_write={4'b0, 4'b1111, 8'b0};
          2'b11: DA_write={4'b1111, 12'b0};
          endcase
        end
	  default: DA_write=16'b0;
      endcase
    end
    else begin
      DA_in=128'b0;
      DA_write=16'b0;
    end

    // valid=valid;
  end
  WRITE_END:begin
    index=core_addr_reg[9:4];
    //tag array
    TA_write=1'b0;
    TA_read=1'b1;
    TA_in=22'b0;
    //data array
    DA_write=16'b0;
    DA_read=1'b1;
    DA_in=128'b0;      

    // valid=valid;
  end
  default:begin
    index=core_addr_reg[9:4];
    //tag array
    TA_write=1'b0;
    TA_read=1'b0;
    TA_in=22'b0;
    //data array
    DA_write=16'b0;
    DA_read=1'b0;
    DA_in=128'b0;

    // valid=64'b0;
  end
  endcase
end


//register
always_ff@(posedge clk or posedge rst)begin
  if(rst)begin
    core_addr_reg<=32'b0;
    core_req_reg<=1'b0;
    core_write_reg<=1'b0;
    core_in_reg<=32'b0;
    core_type_reg<=3'b0;
    pstate<=3'b0;
    TA_out_reg<=22'b0;
  end
  else begin
    pstate<=state;
    case(state)
    IDLE:begin
      core_addr_reg<=core_addr;
      core_req_reg<=core_req;
      core_write_reg<=core_write;
      core_in_reg<=core_in;
      core_type_reg<=core_type;
      TA_out_reg<=TA_out;
    end
    default:begin
      core_addr_reg<=core_addr_reg;
      core_req_reg<=core_req_reg;
      core_write_reg<=core_write_reg;
      core_in_reg<=core_in_reg;
      core_type_reg<=core_type_reg;
      TA_out_reg<=TA_out_reg;
    end
    endcase
  end
end

//counter
always_ff@(posedge clk or posedge rst)begin
  if(rst)begin
    counter<=2'b0;
	valid<=64'b0;
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

always_ff@(posedge clk or posedge rst) begin
  if(rst) hit<=1'b0;
  else begin
    case(state)
    IDLE:begin
      hit <= valid[core_addr_reg[9:4]] & TA_out==core_addr[31:10];
    end
    default:begin
      hit <= valid[core_addr_reg[9:4]] & TA_out_reg==core_addr_reg[31:10];
    end
    endcase
  end
end

endmodule

