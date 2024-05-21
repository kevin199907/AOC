# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
import torch

from .base import BaseObserver


class MinmaxObserver(BaseObserver):

    def __init__(self, module_type, bit_type, calibration_mode, first=False):
        super(MinmaxObserver, self).__init__(module_type, bit_type,
                                             calibration_mode, first)
        self.symmetric = self.bit_type.signed
        self.first = first

    def update(self, v):
        v = self.reshape_tensor(v)
        cur_max = v.max(axis=1).values
        if self.max_val is None:
            self.max_val = cur_max                                  #channel wise
        else:
            self.max_val = torch.max(cur_max, self.max_val)
        cur_min = v.min(axis=1).values
        if self.min_val is None:
            self.min_val = cur_min                         
        else:
            self.min_val = torch.min(cur_min, self.min_val)         #layer wise

        if self.calibration_mode == 'layer_wise':
            self.max_val = self.max_val.max()
            self.min_val = self.min_val.min()

    def get_quantization_params(self, *args, **kwargs):
        max_val = self.max_val
        min_val = self.min_val
        one = torch.tensor(1).cuda() 
        
        qmax = self.bit_type.upper_bound
        qmin = self.bit_type.lower_bound

        scale = torch.ones_like(max_val, dtype=torch.float32)      #scale = FP32  #probabliy channel wise or layer wise
        zero_point = torch.zeros_like(max_val, dtype=torch.int64)  #zero_point = int 64
        
        
        if self.module_type == 'activation':
            max_val = torch.max(min_val.abs(), max_val)
            #scale = max_val / (float(qmax - qmin) )  #qmax=255 ,qmin=0
            if self.first :
                scale = (float(qmax - qmin  ) )/ one
            else :
                scale = (float(qmax - qmin) ) / max_val  #qmax=255 ,qmin=0
            #scale.clamp_(self.eps)   # let scale dont be too large   ?? why?
            zero_point = torch.zeros_like(max_val, dtype=torch.int64)        
            
            
            
            
        elif self.symmetric:
            max_val = torch.max(min_val.abs(), max_val)
            #scale = max_val / (float(qmax - qmin) / 2)   #127- (-128)  /2 = 255/2 
            #scale = max_val / (float(qmax ) )   #127 
            scale = (float(qmax ) )  / max_val
            #scale.clamp_(self.eps)   # let scale dont be too large   ?? why?
            zero_point = torch.zeros_like(max_val, dtype=torch.int64)
        else:
            #scale = (max_val - min_val) / float(qmax - qmin)
            scale = float(qmax - qmin) /(max_val - min_val)
            #scale.clamp_(self.eps)
            zero_point = qmin - torch.round(min_val / scale)
            zero_point.clamp_(qmin, qmax)
        return scale, zero_point


