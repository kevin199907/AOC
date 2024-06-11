void DMA_off(){
    unsigned int *DMA_ctrl_addr = (unsigned int*)0x50004000;
    *DMA_ctrl_addr = 0;
    return;
};

void Interrupt_Selection(){

    DMA_off();
    return;
};