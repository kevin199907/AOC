void DMA_off(){
    int *DMA_ctrl_addr = (int*)0x50004000;
    *DMA_ctrl_addr = 0;
};