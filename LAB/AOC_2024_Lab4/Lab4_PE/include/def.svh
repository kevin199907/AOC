`define Psum_BITS 24 
`define filter_col 3
`define stride 1  

//different tb parameters
`ifdef tb0	// entry-level 
	`define channel 3'd4	// 4 channel  
	`define ifmap_col 6'd5  // ifmap column 5
	`define ofmap_col 6'd3	// ofmap column 3
	`define ifmap_bit 4'd8	// 8 bit ifmap
	`define filter_bit 4'd8	// 8 bit filter 
	
	`define batch_size 2'd1 // 1 image
	`define pro_pass 13'd1 	// a processing pass : 16 kernels
	`define ofmap_total 48	// number of ofmap output 48 // 1*16*3
	`define kernel 16	
	// 20 ifmap
	// 192 weights
	// 48 ofmap
`endif


`ifdef tb1	// VGG16-cifar10 first layer 
	`define channel 3'd3	 // colorful image 3
	`define ifmap_col 6'd34  // ifmap column 34
	`define ofmap_col 6'd32	 // ofmap column 32
	`define ifmap_bit 4'd8	 // 8 bit ifmap
	`define filter_bit 4'd8	 // 8 bit filter
	
	`define batch_size 2'd1  // 1 image
	`define pro_pass 13'd4 	 // 4 processing pass : 16*4 kernels
	`define ofmap_total 2048 // number of ofmap output 2048 // 1*32*64
	`define kernel 64
	// 102 ifmap
	// 576 weights
	// 2048 ofmap	
`endif


`ifdef tb2	// batch size 2  // zero 
	`define channel 3'd4	 // 4 channel
	`define ifmap_col 6'd18  // ifmap column 18
	`define ofmap_col 6'd16  // ofmap column 16
	`define ifmap_bit 4'd8	 // 8 bit ifmap
	`define filter_bit 4'd8	 // 8 bit filter
	
	`define batch_size 2'd2  // 2 image
	`define pro_pass 13'd1 	 // 1 processing pass : 16 kernels	
	`define ofmap_total 512  // number of ofmap output 512 // 2*16*16
	`define kernel 16
	// 144 ifmap
	// 192 weights
	// 512 ofmap
`endif


`ifdef tb3	// test hybrid multiplier and adder
	`define channel 3'd4	// 4 channel  
	`define ifmap_col 6'd10  // ifmap column 10
	`define ofmap_col 6'd8	// ofmap column 8
	`define ifmap_bit 4'd4	// 4 bit ifmap
	`define filter_bit 4'd4	// 4 bit filter 
	
	`define batch_size 2'd1 // 1 image
	`define pro_pass 13'd1 	// 1 processing pass : 32 kernels
	`define ofmap_total 128	// number of ofmap output 24 //  (1*32*8 / 2)
	`define kernel 32
	// 40 ifmap
	// 384 weights
	// 128 ofmap
`endif
  



