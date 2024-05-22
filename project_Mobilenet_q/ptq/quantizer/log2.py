# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
import torch

from .base import BaseQuantizer


class Log2Quantizer(BaseQuantizer):

    def __init__(self, bit_type, observer, module_type):
        super(Log2Quantizer, self).__init__(
            bit_type,
            observer,
            module_type,
        )
        self.softmax_mask = None
        self.sign = None
        self.rounds = None
        
    def quant(self, inputs):
        self.sign = inputs.sign()
        
        
        inputs = inputs.abs()
        
        self.rounds = torch.round(-1 * inputs.log2())
        self.softmax_mask = self.rounds >= 2**self.bit_type.bits
     
        # breakpoint()
        # if self.softmax_mask == None:
            # print('hello !!!!')
            # print(self.module_type)
  
        outputs = torch.clamp(self.rounds, 0, 2**self.bit_type.bits - 1)
        #outputs = outputs*sign
        
        
        return outputs

    def dequantize(self, inputs):
        outputs = 2**(-1 * inputs)
        outputs = outputs*self.sign
        outputs[self.softmax_mask] = 0   #value too small to be 0
        return outputs
