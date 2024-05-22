# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
import torch
import torch.nn as nn

from .base import BaseQuantizer


class OutputQuantizer(BaseQuantizer):

    def __init__(self, bit_type, observer, module_type):
        super(OutputQuantizer, self).__init__(bit_type, observer, module_type)
        self.scale = None
        self.zero_point = None
        self.quanted_val = None

    def update_quantization_params(self, *args, **kwargs):
        self.scale, self.zero_point = self.observer.get_quantization_params(
            *args, **kwargs)

    def quant(self, inputs, scale=None, zero_point=None):
        if scale is None:
            scale = self.scale
        if zero_point is None:
            zero_point = self.zero_point
        range_shape = self.get_reshape_range(inputs)
        scale = scale.reshape(range_shape)
        zero_point = zero_point.reshape(range_shape)
        outputs = inputs * scale + zero_point
        
        self.inputs = inputs
        
        if self.module_type == 'activation':
            outputs = outputs.round().clamp(self.bit_type.lower_bound ,
                                        self.bit_type.upper_bound) #(0~255)
        else :
            outputs = outputs.round().clamp((-1)*self.bit_type.upper_bound ,
                                        self.bit_type.upper_bound) #(-127~127)
        
        
        
        
        self.quanted_val = outputs
        #breakpoint()
        return outputs

    def dequantize(self, inputs, scale=None, zero_point=None):
        # if scale is None:
            # scale = self.scale
        # if zero_point is None:
            # zero_point = self.zero_point
            
        int_output = inputs
        scale = self.scale
        zero_point = self.zero_point
        range_shape = self.get_reshape_range(inputs)
        scale = scale.reshape(range_shape)
        zero_point = zero_point.reshape(range_shape)
        outputs = (inputs - zero_point) / scale
        return outputs ,self.scale, int_output