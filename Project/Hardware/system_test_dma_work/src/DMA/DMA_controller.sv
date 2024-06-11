module DMA_controller(
    input clk,
    input rst,
    input wfi_signal,
    //slave
    input [3:0] dmareg_wen,
    input [31:0] dmareg_addr,
    input [31:0] dmareg_data,

    //output
    output logic read_signal,
    output logic [31:0] current_addr_read,
    output logic [31:0] current_addr_write,
    output logic done ,//intr

    input BVALID, BREADY, RLAST
);
////////declare////////
////dma registers////
logic [31:0]    src_address;
logic [31:0]    dest_address;
logic [31:0]    data_length;
logic           start_bit;

logic [31:0] current_addr;
logic [31:0] end_address;

assign end_address= dest_address + (data_length<<2);

assign current_addr_read=current_addr+src_address;
assign current_addr_write=current_addr+dest_address;

////state machine////
typedef enum [2:0] {
    INIT, TRANSFER_BURST, STOP_READING, BREAK, DONE
} state_type;
state_type state, nstate;

////////////////////////

always_ff@(posedge clk or posedge rst)begin
    if(rst) state<=INIT;
    else state<=nstate;
end

always_comb begin
    case(state)
    INIT:begin
        if(start_bit && wfi_signal) nstate=TRANSFER_BURST;
        else nstate=INIT;
    end
    TRANSFER_BURST:begin
        if(RLAST) nstate=STOP_READING;
        else nstate=TRANSFER_BURST;
    end
    STOP_READING:begin
        if(BVALID && BREADY) nstate=BREAK;
        else nstate=STOP_READING;
    end
    BREAK:begin
        if(current_addr_write + 32'd64 < end_address) nstate=TRANSFER_BURST;
        else nstate=DONE;
    end
    DONE:begin
        if(~start_bit)nstate=INIT;
        else nstate=DONE;
    end
    default:begin
        nstate=INIT;
    end
    endcase
end

//output logic
always_comb begin
    case(state)
    INIT:begin
       read_signal=1'b0;    
       done=1'b0;     
    end
    TRANSFER_BURST:begin
       read_signal=1'b1;   
       done=1'b0;        
    end
    STOP_READING:begin
       read_signal=1'b0;   
       done=1'b0; 
    end
    BREAK:begin
       read_signal=1'b0;
       done=1'b0;          
    end
    DONE:begin
       read_signal=1'b0;
       done=1'b1;         
    end
    default:begin
        read_signal=1'b0;
        done=1'b0; 
    end
    endcase

end

////current address reg////
always_ff@(posedge clk or posedge rst)begin
    if(rst)begin
        current_addr<=32'b0;
    end
    else begin
        case(state)
        INIT:begin
           current_addr<=32'b0;            
        end
        TRANSFER_BURST:begin
           current_addr<=current_addr;          
        end
        STOP_READING:begin
           current_addr<=current_addr;          
        end
        BREAK:begin
           current_addr<=current_addr+32'd64;        
        end
        DONE:begin
           current_addr<=current_addr;         
        end
        default:begin
            current_addr<=current_addr;  
        end
        endcase
    end
end

////dma registers////
always@(posedge clk or posedge rst)begin
    if(rst)begin
        src_address     <=32'b0;
        dest_address    <=32'b0;
        data_length     <=32'b0;
        start_bit       <=1'b0;
    end
    else begin
        case(state)
        INIT:begin
            if(dmareg_wen==4'b1111)begin
                case(dmareg_addr)
                32'h5000_1000:begin // source address: 0x5000_1000
                    src_address     <=dmareg_data;
                    dest_address    <=dest_address;
                    data_length     <=data_length;
                    start_bit    <=start_bit;    
                end
                32'h5000_2000:begin // destination address: 0x5000_2000
                    src_address     <=src_address;
                    dest_address    <=dmareg_data;
                    data_length     <=data_length;
                    start_bit    <=start_bit;    
                end
                32'h5000_3000:begin // data length: 0x5000_3000
                    src_address     <=src_address;
                    dest_address    <=dest_address;
                    data_length     <=dmareg_data;
                    start_bit    <=start_bit;    
                end
                32'h5000_4000:begin // start signal: 0x5000_4000
                    src_address     <=src_address;
                    dest_address    <=dest_address;
                    data_length     <=data_length;
                    start_bit    <=dmareg_data[0];    
                end
                default:begin
                    src_address     <=src_address;
                    dest_address    <=dest_address;
                    data_length     <=data_length;
                    start_bit    <=start_bit;    
                end
                endcase
            end
            else begin
                src_address     <=src_address;
                dest_address    <=dest_address;
                data_length     <=data_length;
                start_bit    <=start_bit;
            end
        end
        DONE:begin
            if(dmareg_wen==4'b1111)begin
                case(dmareg_addr)
                32'h5000_4000:begin // start signal: 0x5000_4000
                    src_address     <=src_address;
                    dest_address    <=dest_address;
                    data_length     <=data_length;
                    start_bit    <=dmareg_data[0];    
                end
                default:begin
                    src_address     <=src_address;
                    dest_address    <=dest_address;
                    data_length     <=data_length;
                    start_bit    <=start_bit;    
                end
                endcase
            end
            else begin
                src_address     <=src_address;
                dest_address    <=dest_address;
                data_length     <=data_length;
                start_bit    <=start_bit;
            end
        end
        default:begin
            src_address     <=src_address;
            dest_address    <=dest_address;
            data_length     <=data_length;
            start_bit    <=start_bit;
        end
        endcase
    end
end

endmodule