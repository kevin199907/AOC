# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
import torch
import torch.nn as nn
import math
from torch.nn import functional as F

from .bit_type import BIT_TYPE_DICT
from .observer import build_observer
from .quantizer import build_quantizer
import pdb

def reshape_to_activation(input):
  return input.reshape(1, -1, 1, 1)
def reshape_to_weight(input):
  return input.reshape(-1, 1, 1, 1)
  
def reshape_to_weight_transpose(input):
  return input.reshape(1, -1, 1, 1)  
  
def reshape_to_bias(input):
  return input.reshape(-1)

class RoundWithGradient(torch.autograd.Function):   #對小數第一位四捨五入 往0的方向   -0.4 => 0
    @staticmethod
    def forward(ctx, x):
        return x.round()
        #return round_bit(x, r=0)  # round operation
    @staticmethod
    def backward(ctx, g):
        return g 
        
        
class QConv2d(nn.Conv2d):
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1, bias=True, quant=False, calibrate=False, last_calibrate=False, bit_type=BIT_TYPE_DICT['int8'], calibration_mode='layer_wise', observer_str='minmax', quantizer_str='uniform', QAT = False ):
        super(QConv2d, self).__init__(in_channels=in_channels, out_channels=out_channels, kernel_size=kernel_size, stride=stride, padding=padding, dilation=dilation, groups=groups, bias=bias,)
        self.quant = quant
        self.QAT = QAT
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str

        self.module_type = 'conv_weight'
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        #self.observer_bias = build_observer(self.observer_str, self.module_type,
        #                               self.bit_type, 'layer_wise')
        #self.quantizer_bias = build_quantizer(self.quantizer_str, self.bit_type,
        #                                 self.observer_bias, self.module_type)
                                         
                                         
                                         
        self.weight_scale = torch.nn.Parameter(torch.ones(out_channels)) #channel-wise
        self.weight_int = torch.nn.Parameter(torch.zeros(self.weight.size()))
        
        #below for QAT
        self.wgt_bit = 8
        self.act_bit = 8
        self.wgt_range=2**(self.wgt_bit-1)-1 #-127~127
        self.act_range=2**(self.act_bit)-1   #0~255
        self.wgt_alpha = torch.nn.Parameter(torch.ones(1))  # will update
        #self.wgt_alpha = torch.nn.Parameter(torch.tensor(2823.))
        self.act_alpha = torch.nn.Parameter(torch.ones(1))   # will update
        self.register_buffer('running_max', torch.zeros(1))
        self.register_buffer('running_num', torch.zeros(1))
        
    def sgn(self, x):
        x = RoundWithGradient.apply(x)
        return x
    
    def forward(self, x):
        
        if self.calibrate:
            self.quantizer.observer.update(self.weight)
            if self.last_calibrate:
                #print('quantizer.update_quantization_params')
                self.quantizer.update_quantization_params(x)
                #print('update_quantization scale = {}'.format(self.quantizer.scale))
                
                
        if not self.quant:  #not PTQ
            if self.QAT :   #QAT part
                weight = self.weight*self.wgt_alpha         
                self.weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                self.weight_q = self.sgn(self.weight_c)
                self.weight_de_q = self.weight_q/self.wgt_alpha 
                
                self.act_reg_QAT = x
                self.input = x
                input = x*self.act_alpha
                input_c = input.clamp(min=0, max=self.act_range)
                self.input_q = self.sgn(input_c)
                self.input_de_q = self.input_q/self.act_alpha
            

                # output=linear_int8(input_q, weight_q, self.bias)
                #self.output1 = F.linear(self.input_de_q, self.weight_de_q, self.bias)  # quantized x and weight  do  int linear
                self.output1 = F.conv2d(self.input_de_q, self.weight_de_q ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                #self.output2 = F.linear(x, self.weight, self.bias)
                self.output2 = F.conv2d(x, self.weight ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                
                
                output = self.output1
                
                return output
            
            
            else :   #baseline part
                input_max=x.max()
                self.act_reg = x
                with torch.no_grad():
                    if self.running_num==0:
                        self.running_max.add_(input_max)
                        self.running_num.add_(1)
                        #print('running_max = {}'.format(self.running_max))
                    else:
                        r=0.1
                        self.running_max.mul_(1 - r).add_(input_max*r)
                        #print('running_max = {}'.format(self.running_max))
                        
                self.act_alpha.data=self.act_range/self.running_max.data  #
                self.wgt_alpha.data=self.wgt_range/self.weight.data.max()
                #output=F.linear(x, self.weight, self.bias)
    
                return F.conv2d(
                    x,
                    self.weight,
                    self.bias,
                    self.stride,
                    self.padding,
                    self.dilation,
                    self.groups,
                )
            
            
            
        # PTQ Part
            
        #print('the weight input type of conv2d  is : {} '.format(type(self.weight)))
        buffer1 = self.quantizer(self.weight)
        #buffer2 = self.quantizer_bias(self.bias)
        
        self.weight       = nn.Parameter( buffer1[0] )  
        self.weight_scale = nn.Parameter( buffer1[1] )
        self.weight_int   = nn.Parameter( buffer1[2] )
        #self.bias, self.bias_scale, self.bias_int       = nn.Parameter( self.quantizer(self.bias) )
        # self.bias       = nn.Parameter( buffer2[0] )  
        # self.bias_scale = nn.Parameter( buffer2[1] )
        # self.bias_int   = nn.Parameter( buffer2[2] )
        
        
        return F.conv2d(x, self.weight, self.bias, self.stride, self.padding,
                        self.dilation, self.groups)


class QConv2d_BNFold(nn.Conv2d):

    def __init__(self,
                 in_channels,
                 out_channels,
                 kernel_size,
                 stride=1,
                 padding=0,
                 dilation=1,
                 groups=1,
                 bias=False,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform',
                 
                 bit_type_act=BIT_TYPE_DICT['uint8'],
                 calibration_mode_act='layer_wise',
                 observer_str_act='minmax',
                 quantizer_str_act='uniform',
                 
                 
                 QAT = False,
                 first = False,
                 momentum=0.1,
                 eps=1e-6,):
        super(QConv2d_BNFold, self).__init__(
            in_channels=in_channels,
            out_channels=out_channels,
            kernel_size=kernel_size,
            stride=stride,
            padding=padding,
            dilation=dilation,
            groups=groups,
            bias=bias,
        )
        self.quant = quant
        self.QAT = QAT
        self.first = first
        
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str
        
        self.bit_type_act = bit_type_act
        self.calibration_mode_act = calibration_mode_act
        self.observer_str_act = observer_str_act
        self.quantizer_str_act = quantizer_str_act
        
        self.layer_type = 'QConv2d_BNFold'
        self.module_type = 'conv_weight'
        self.module_type_act = 'activation'
        
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        self.observer_act = build_observer(self.observer_str_act, self.module_type_act,
                                       self.bit_type_act, self.calibration_mode_act,first = self.first )
        self.quantizer_act = build_quantizer(self.quantizer_str_act, self.bit_type_act,
                                         self.observer_act, self.module_type_act)
                                         
        

        
                                         
        #self.observer_bias = build_observer(self.observer_str, self.module_type,
        #                               self.bit_type, 'layer_wise')
        #self.quantizer_bias = build_quantizer(self.quantizer_str, self.bit_type,
        #                                 self.observer_bias, self.module_type)
                                         
                                         
                                         
        #self.weight_scale = torch.nn.Parameter(torch.ones(out_channels)) #channel-wise
        self.weight_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        self.act_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        
        #below for QAT
        self.wgt_bit = 8
        self.act_bit = 8
        self.wgt_range=2**(self.wgt_bit-1)-1 #-127~127
        self.act_range=2**(self.act_bit)-1   #0~255
        self.bias_range=(2**15)-1 # -bias_range ~ bias_range   bias 16 bits
        self.wgt_alpha = torch.nn.Parameter(torch.ones(1))  # will update
        #self.wgt_alpha = torch.nn.Parameter(torch.tensor(2823.))
        self.act_alpha = torch.nn.Parameter(torch.ones(1))   # will update
        self.register_buffer('running_max', torch.zeros(1))
        self.register_buffer('running_num', torch.zeros(1))
        
        self.eps = eps
        self.momentum = momentum
        self.gamma  = torch.nn.Parameter(torch.ones(out_channels))
        self.beta   = torch.nn.Parameter(torch.zeros(out_channels))
        
        self.register_buffer('first_bn', torch.zeros(1))
        self.register_buffer('running_mean', torch.zeros(out_channels))
        self.register_buffer('running_var', torch.ones(out_channels))
        self.first=first
        
        # self.gamma.data.fill_(0.5)
        # self.beta.data.zero_()

    def sgn(self, x):
        x = RoundWithGradient.apply(x)
        return x
    
    def forward(self, x):
        if not self.quant:  #not PTQ
            if self.QAT :   #QAT part
                weight = self.weight*self.wgt_alpha         
                self.weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                self.weight_q = self.sgn(self.weight_c)
                self.weight_de_q = self.weight_q/self.wgt_alpha 
                
                self.act_reg_QAT = x
                self.input = x
                input = x*self.act_alpha
                input_c = input.clamp(min=0, max=self.act_range)
                self.input_q = self.sgn(input_c)
                self.input_de_q = self.input_q/self.act_alpha
            

                # output=linear_int8(input_q, weight_q, self.bias)
                #self.output1 = F.linear(self.input_de_q, self.weight_de_q, self.bias)  # quantized x and weight  do  int linear
                self.output1 = F.conv2d(self.input_de_q, self.weight_de_q ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                #self.output2 = F.linear(x, self.weight, self.bias)
                self.output2 = F.conv2d(x, self.weight ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                
                
                output = self.output1
                
                return output
            
            
            else :   #baseline part
                if self.training:
                    output = F.conv2d(
                        input=x,
                        weight=self.weight,
                        bias=self.bias,
                        stride=self.stride,
                        padding=self.padding,
                        dilation=self.dilation,
                        groups=self.groups
                    )
                    dims = [dim for dim in range(4) if dim != 1]   #[N H W]
                    batch_mean = torch.mean(output, dim=dims)   #on  [N H W]
                    batch_var = torch.var(output, dim=dims)     #on  [N H W]
                    with torch.no_grad():
                        if self.first_bn == 0:
                            self.first_bn.add_(1)
                            self.running_mean.add_(batch_mean)
                            self.running_var.add_(batch_var)
                        else:
                            self.running_mean.mul_(1 - self.momentum).add_(batch_mean * self.momentum)   #calculate running mean on batch
                            self.running_var.mul_(1 - self.momentum).add_(batch_var * self.momentum)
            
                    if self.bias is not None: 
                        bias_batch = reshape_to_bias(self.beta + (self.bias - batch_mean) * (self.gamma / torch.sqrt(batch_var + self.eps))) # reshape_to_bias??
                        bias_fused = reshape_to_bias(self.beta + (self.bias - self.running_mean) * (self.gamma / torch.sqrt(self.running_var + self.eps)))
                    else:
                        bias_batch = reshape_to_bias(self.beta - batch_mean * (self.gamma / torch.sqrt(batch_var + self.eps)))  #和上面差在 不用加  elf.bias ??
                        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))  #fused 為何要self.running_var
                    bias_diff=bias_batch - bias_fused
                    weight_batch = self.weight * reshape_to_weight(self.gamma / torch.sqrt(batch_var + self.eps))    
                else:
                    bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
                    weight_fused = self.weight * reshape_to_weight(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
                    
                if self.QAT:  # 以下QAT
                    # Clamp alpha to power of two for making M0=1
                    #self.wgt_alpha.data = self.PoT(self.wgt_alpha)
                    #self.act_alpha.data = self.PoT(self.act_alpha)
                    
                    if self.first:
                        x= x*self.act_range #為何第一層輸入乘上255 ?? 他沒有自己的alpha?  
                    else:
                        x= x*self.act_alpha               #*scale
                    input_c = x.clamp(min=0, max=self.act_range)
                    input_q = self.sgn(input_c)
                    
                    if self.training:
                        weight = weight_batch*self.wgt_alpha     #training 時 weight_batch
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
            
                        if self.first:
                            bias = bias_batch*self.wgt_alpha*self.act_range    # *self.act_range ???
                        else:
                            bias = bias_batch*self.wgt_alpha*self.act_alpha    # *self.act_alpha ???
                        
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        # print(self.wgt_alpha)
                        weight = weight_fused*self.wgt_alpha          #inference  時 weight_fused
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
                        
                        if self.first:
                            bias = bias_fused*self.wgt_alpha*self.act_range   # *self.act_range ???
                        else:
                            bias = bias_fused*self.wgt_alpha*self.act_alpha   # *self.act_alpha ???
                            
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
                        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    noise=torch.randn(output.shape).cuda()
                    output=output+self.weight.shape[1]*noise*1    #  self.weight.shape[1]??
        
                    if self.first:
                        output=output/self.act_range/self.wgt_alpha   # /self.act_range ???
                    else:
                        output=output/self.act_alpha/self.wgt_alpha  # /self.act_alpha ???
                else:  # FP training
                    if self.training:
                        input_max=torch.max(x.abs().view(x.shape[0],-1),dim=1)[0]
                        input_max=input_max.mean()
                        
                        with torch.no_grad():
                            if self.running_num==0:
                                self.running_max.add_(input_max)
                                self.running_num.add_(1)
                            else:
                                r=0.1
                                self.running_max.mul_(1-r).add_(input_max*r)
                        self.act_alpha.data=self.act_range/self.running_max.data    #training 時訓練act_alpha?
                        self.wgt_alpha.data=self.wgt_range/weight_batch.data.max()  #training 時訓練wgt_alpha?
                        output=F.conv2d(x, weight_batch, bias_batch, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
                        weight_fused = self.weight * reshape_to_weight(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
                        self.weight_fused = weight_fused
                        self.bias_fused = bias_fused
                        self.act_reg = x  #for plot
                        
                        if self.calibrate :
                            self.quantizer.observer.update(weight_fused)
                            self.quantizer_act.observer.update(x)
                            if self.observer_str_act =='entropy' :
                                self.input_max_entropy = self.quantizer_act.observer.max_val
                                self.calib_reduce_num  = self.quantizer_act.observer.calib_reduce_num
                                self.input_true_that_time  = self.quantizer_act.observer.input_true_that_time
                                self.input_max_true_that_time  = self.quantizer_act.observer.input_max_true_that_time
                                self.input_max_test  = self.quantizer_act.observer.input_max_test
                                self.input_test  = self.quantizer_act.observer.input_test
                            
                            #print('in calibrate')
                            if self.last_calibrate:
                                print('max value: ',self.quantizer_act.observer.max_val)
                                print('min value: ',self.quantizer_act.observer.min_val)
                                #print('quantizer.update_quantization_params')
                                self.quantizer.update_quantization_params(weight_fused)
                                self.quantizer_act.update_quantization_params(x)
                                print('scaling factor wgt: ',self.quantizer.scale)
                                print('scaling factor act: ',self.quantizer_act.scale)
                                #print('update_quantization scale = {}'.format(self.quantizer.scale))
                                #print('last calibrate')
                                #breakpoint()
                        
                        output=F.conv2d(x, weight_fused, bias_fused, self.stride, self.padding, self.dilation, self.groups)  #inference 時直接用fused?  和162 178行差在哪
                return output
          
         
                #==== new version ====
        # ====PTQ Part

                
        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
        weight_fused = self.weight * reshape_to_weight(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
        
        
        
        
        
        #print('the weight input type of conv2d  is : {} '.format(type(self.weight)))
        buffer1 = self.quantizer(weight_fused)
        #buffer2 = self.quantizer_bias(self.bias)
        self.weight_int = torch.nn.Parameter(torch.zeros(self.weight.size()))
        
        self.weight_original = weight_fused
        
        # self.weight       = nn.Parameter( buffer1[0] )  
        self.weight_scale = nn.Parameter( buffer1[1] )
        self.weight_int   = nn.Parameter( buffer1[2] )
        #self.bias, self.bias_scale, self.bias_int       = nn.Parameter( self.quantizer(self.bias) )
        # self.bias       = nn.Parameter( buffer2[0] )  
        # self.bias_scale = nn.Parameter( buffer2[1] )
        # self.bias_int   = nn.Parameter( buffer2[2] )
        
        # ====act quant===
        buffer2 = self.quantizer_act(x)
        #buffer2 = self.quantizer_bias(self.bias)
        self.act_int = torch.nn.Parameter(torch.zeros(x.size()))
        
        
        self.x_dequant    = nn.Parameter( buffer2[0] )  
        self.act_scale    = nn.Parameter( buffer2[1] ) #layer-wise
        self.act_int      = nn.Parameter( buffer2[2] )
         
        #x = self.quantizer(x)
        #return self.x_dequant   #fake quantize fp32
        # ====act quant===
        self.act_reg = x
        
        self.bias_fused = bias_fused
        
        if self.first:
            bias = bias_fused*self.weight_scale*self.act_range   # *self.act_range ???
        else:
            bias = bias_fused*self.weight_scale*self.act_scale   # *self.act_alpha ???
            
        
            
        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
        bias_q = self.sgn(bias_c)
        
        self.bias_fused_quant_int = bias_q
        
        if self.first:
            self.bias_de_q = bias_q/self.weight_scale/self.act_range 
        else :
            self.bias_de_q = bias_q/self.weight_scale/self.act_scale 
        
        output = F.conv2d(self.x_dequant, weight_fused, self.bias_de_q, self.stride, self.padding,
                        self.dilation, self.groups)
                        
        self.output = output 
        # pdb.set_trace() 
        return output
                        
                        
                        
                        
class QConvTranspose2d_BNFold(nn.ConvTranspose2d):

    def __init__(self,
                 in_channels,
                 out_channels,
                 kernel_size,
                 stride=1,
                 padding=0,
                 output_padding=0,
                 dilation=1,
                 groups=1,
                 bias=False,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform',
                 
                 bit_type_act=BIT_TYPE_DICT['uint8'],
                 calibration_mode_act='layer_wise',
                 observer_str_act='minmax',
                 quantizer_str_act='uniform',
                 
                 
                 QAT = False,
                 first = False,
                 momentum=0.1,
                 eps=1e-6,):
        super(QConvTranspose2d_BNFold, self).__init__(
            in_channels=in_channels,
            out_channels=out_channels,
            kernel_size=kernel_size,
            stride=stride,
            padding=padding,
            dilation=dilation,
            groups=groups,
            bias=bias,
            output_padding=output_padding
        )
        self.quant = quant
        self.QAT = QAT
        self.first = first
        
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str
        
        self.bit_type_act = bit_type_act
        self.calibration_mode_act = calibration_mode_act
        self.observer_str_act = observer_str_act
        self.quantizer_str_act = quantizer_str_act
        
        self.layer_type = 'QConv2d_BNFold'
        self.module_type = 'conv_weight'
        self.module_type_act = 'activation'
        
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        self.observer_act = build_observer(self.observer_str_act, self.module_type_act,
                                       self.bit_type_act, self.calibration_mode_act, first = self.first)
        self.quantizer_act = build_quantizer(self.quantizer_str_act, self.bit_type_act,
                                         self.observer_act, self.module_type_act)
                                         
        

        
                                         
        #self.observer_bias = build_observer(self.observer_str, self.module_type,
        #                               self.bit_type, 'layer_wise')
        #self.quantizer_bias = build_quantizer(self.quantizer_str, self.bit_type,
        #                                 self.observer_bias, self.module_type)
                                         
                                         
                                         
        #self.weight_scale = torch.nn.Parameter(torch.ones(out_channels)) #channel-wise
        self.weight_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        self.act_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        
        #below for QAT
        self.wgt_bit = 8
        self.act_bit = 8
        self.wgt_range=2**(self.wgt_bit-1)-1 #-127~127
        self.act_range=2**(self.act_bit)-1   #0~255
        self.bias_range=(2**15)-1 # -bias_range ~ bias_range   bias 16 bits
        self.wgt_alpha = torch.nn.Parameter(torch.ones(1))  # will update
        #self.wgt_alpha = torch.nn.Parameter(torch.tensor(2823.))
        self.act_alpha = torch.nn.Parameter(torch.ones(1))   # will update
        self.register_buffer('running_max', torch.zeros(1))
        self.register_buffer('running_num', torch.zeros(1))
        
        self.eps = eps
        self.momentum = momentum
        self.gamma = torch.nn.Parameter(torch.ones(out_channels))
        self.beta = torch.nn.Parameter(torch.zeros(out_channels))
        
        self.register_buffer('first_bn', torch.zeros(1))
        self.register_buffer('running_mean', torch.zeros(out_channels))
        self.register_buffer('running_var', torch.ones(out_channels))
        self.first=first
        
        # self.gamma.data.fill_(0.5)
        # self.beta.data.zero_()
        
        # if self.bias is not None:
            # self.bias.data.zero_()
        
        # n = self.kernel_size[0] * self.kernel_size[1] * self.out_channels
        # self.weight.data.normal_(0, math.sqrt(2. / n))   #為何如此/  out_channels


    def sgn(self, x):
        x = RoundWithGradient.apply(x)
        return x
    
    def forward(self, x):
        
        
                
                
     
            
        if not self.quant:  #not PTQ
            
            
            if self.QAT :   #QAT part
                weight = self.weight*self.wgt_alpha         
                self.weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                self.weight_q = self.sgn(self.weight_c)
                self.weight_de_q = self.weight_q/self.wgt_alpha 
                
                self.act_reg_QAT = x
                self.input = x
                input = x*self.act_alpha
                input_c = input.clamp(min=0, max=self.act_range)
                self.input_q = self.sgn(input_c)
                self.input_de_q = self.input_q/self.act_alpha
            

                # output=linear_int8(input_q, weight_q, self.bias)
                #self.output1 = F.linear(self.input_de_q, self.weight_de_q, self.bias)  # quantized x and weight  do  int linear
                self.output1 = F.conv_transpose2d(self.input_de_q, self.weight_de_q ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                #self.output2 = F.linear(x, self.weight, self.bias)
                self.output2 = F.conv_transpose2d(x, self.weight ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                
                
                output = self.output1
                
                return output
            
            
            else :   #baseline part
                # ==== old version ====
                # input_max=x.max()
                # self.act_reg = x
                # with torch.no_grad():
                    # if self.running_num==0:
                        # self.running_max.add_(input_max)
                        # self.running_num.add_(1)
                        # #print('running_max = {}'.format(self.running_max))
                    # else:
                        # r=0.1
                        # self.running_max.mul_(1 - r).add_(input_max*r)
                        # #print('running_max = {}'.format(self.running_max))
                        
                # self.act_alpha.data=self.act_range/self.running_max.data  #
                # self.wgt_alpha.data=self.wgt_range/self.weight.data.max()
                # #output=F.linear(x, self.weight, self.bias)
    
                # return F.conv2d(
                    # x,
                    # self.weight,
                    # self.bias,
                    # self.stride,
                    # self.padding,
                    # self.dilation,
                    # self.groups,
                # )
                #==== old version ====
                
                #==== new version ====
                if self.training:
                    output = F.conv_transpose2d(
                        input=x,
                        weight=self.weight,
                        bias=self.bias,
                        stride=self.stride,
                        padding=self.padding,
                        dilation=self.dilation,
                        groups=self.groups
                    )
                    dims = [dim for dim in range(4) if dim != 1]   #[N H W]
                    batch_mean = torch.mean(output, dim=dims)   #on  [N H W]
                    batch_var = torch.var(output, dim=dims)     #on  [N H W]
                    with torch.no_grad():
                        if self.first_bn == 0:
                            self.first_bn.add_(1)
                            self.running_mean.add_(batch_mean)
                            self.running_var.add_(batch_var)
                        else:
                            self.running_mean.mul_(1 - self.momentum).add_(batch_mean * self.momentum)   #calculate running mean on batch
                            self.running_var.mul_(1 - self.momentum).add_(batch_var * self.momentum)
            
                    if self.bias is not None: 
                        bias_batch = reshape_to_bias(self.beta + (self.bias - batch_mean) * (self.gamma / torch.sqrt(batch_var + self.eps))) # reshape_to_bias??
                        bias_fused = reshape_to_bias(self.beta + (self.bias - self.running_mean) * (self.gamma / torch.sqrt(self.running_var + self.eps)))
                    else:
                        bias_batch = reshape_to_bias(self.beta - batch_mean * (self.gamma / torch.sqrt(batch_var + self.eps)))  #和上面差在 不用加  elf.bias ??
                        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))  #fused 為何要self.running_var
                    bias_diff=bias_batch - bias_fused
                    weight_batch = self.weight * reshape_to_weight_transpose(self.gamma / torch.sqrt(batch_var + self.eps))    
                else:
                    bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
                    weight_fused = self.weight * reshape_to_weight_transpose(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
                    
                    
                    
                if self.QAT:  # 以下QAT
                    # Clamp alpha to power of two for making M0=1
                    #self.wgt_alpha.data = self.PoT(self.wgt_alpha)
                    #self.act_alpha.data = self.PoT(self.act_alpha)
                    
                    if self.first:
                        x= x*self.act_range #為何第一層輸入乘上255 ?? 他沒有自己的alpha?  
                    else:
                        x= x*self.act_alpha               #*scale
                    input_c = x.clamp(min=0, max=self.act_range)
                    input_q = self.sgn(input_c)
                    
                    if self.training:
                        weight = weight_batch*self.wgt_alpha     #training 時 weight_batch
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
            
                        if self.first:
                            bias = bias_batch*self.wgt_alpha*self.act_range    # *self.act_range ???
                        else:
                            bias = bias_batch*self.wgt_alpha*self.act_alpha    # *self.act_alpha ???
                        
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv_transpose2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        # print(self.wgt_alpha)
                        weight = weight_fused*self.wgt_alpha          #inference  時 weight_fused
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
                        
                        if self.first:
                            bias = bias_fused*self.wgt_alpha*self.act_range   # *self.act_range ???
                        else:
                            bias = bias_fused*self.wgt_alpha*self.act_alpha   # *self.act_alpha ???
                            
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
                        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv_transpose2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    noise=torch.randn(output.shape).cuda()
                    output=output+self.weight.shape[1]*noise*1    #  self.weight.shape[1]??
        
                    if self.first:
                        output=output/self.act_range/self.wgt_alpha   # /self.act_range ???
                    else:
                        output=output/self.act_alpha/self.wgt_alpha  # /self.act_alpha ???
                else:  # FP training
                    if self.training:
                        input_max=torch.max(x.abs().view(x.shape[0],-1),dim=1)[0]
                        input_max=input_max.mean()
                        
                        with torch.no_grad():
                            if self.running_num==0:
                                self.running_max.add_(input_max)
                                self.running_num.add_(1)
                            else:
                                r=0.1
                                self.running_max.mul_(1-r).add_(input_max*r)
                        self.act_alpha.data=self.act_range/self.running_max.data    #training 時訓練act_alpha?
                        self.wgt_alpha.data=self.wgt_range/weight_batch.data.max()  #training 時訓練wgt_alpha?
                        output=F.conv_transpose2d(x, weight_batch, bias_batch, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
                        weight_fused = self.weight * reshape_to_weight_transpose(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
                        self.weight_fused = weight_fused
                        self.bias_fused = bias_fused
                        self.act_reg = x  #for plot
                        
                        if self.calibrate :
                            self.quantizer.observer.update(weight_fused)
                            self.quantizer_act.observer.update(x)
                            if self.observer_str_act =='entropy':
                                self.input_max_entropy = self.quantizer_act.observer.max_val
                                self.calib_reduce_num  = self.quantizer_act.observer.calib_reduce_num
                                self.input_true_that_time  = self.quantizer_act.observer.input_true_that_time
                                self.input_max_true_that_time  = self.quantizer_act.observer.input_max_true_that_time
                                self.input_max_test  = self.quantizer_act.observer.input_max_test
                                self.input_test  = self.quantizer_act.observer.input_test
                            if self.last_calibrate:
                                #print('quantizer.update_quantization_params')
                                self.quantizer.update_quantization_params(weight_fused)
                                self.quantizer_act.update_quantization_params(x)
                                #print('update_quantization scale = {}'.format(self.quantizer.scale))
                        output=F.conv_transpose2d(x, weight_fused, bias_fused, self.stride, self.padding, self.dilation, self.groups)  #inference 時直接用fused?  和162 178行差在哪
                return output
          
         
                #==== new version ====
        # ====PTQ Part
        bias_fused = reshape_to_bias(self.beta - self.running_mean * (self.gamma / torch.sqrt(self.running_var + self.eps)))#和129行一樣
        weight_fused = self.weight * reshape_to_weight_transpose(self.gamma / torch.sqrt(self.running_var + self.eps))   #fused 為何要self.running_var
        
          
        #print('the weight input type of conv2d  is : {} '.format(type(self.weight)))
        buffer1 = self.quantizer(weight_fused)
        #buffer2 = self.quantizer_bias(self.bias)
        self.weight_int = torch.nn.Parameter(torch.zeros(self.weight.size()))
        
        self.weight_original = self.weight_fused
        
        # self.weight       = nn.Parameter( buffer1[0] )  
        self.weight_scale = nn.Parameter( buffer1[1] )
        self.weight_int   = nn.Parameter( buffer1[2] )
        #self.bias, self.bias_scale, self.bias_int       = nn.Parameter( self.quantizer(self.bias) )
        # self.bias       = nn.Parameter( buffer2[0] )  
        # self.bias_scale = nn.Parameter( buffer2[1] )
        # self.bias_int   = nn.Parameter( buffer2[2] )
        
        # ====act quant===
        buffer2 = self.quantizer_act(x)
        #buffer2 = self.quantizer_bias(self.bias)
        self.act_int = torch.nn.Parameter(torch.zeros(x.size()))
        
        
        self.x_dequant    = nn.Parameter( buffer2[0] )  
        self.act_scale    = nn.Parameter( buffer2[1] ) #layer-wise
        self.act_int      = nn.Parameter( buffer2[2] )
         
        #x = self.quantizer(x)
        #return self.x_dequant   #fake quantize fp32
        # ====act quant===
        self.act_reg = x
        
        self.bias_fused = bias_fused
        
        if self.first:
            bias = bias_fused*self.weight_scale*self.act_range   # *self.act_range ???
        else:
            bias = bias_fused*self.weight_scale*self.act_scale   # *self.act_alpha ???
            
           
            
        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
        bias_q = self.sgn(bias_c)
        
        self.bias_fused_quant_int = bias_q
        
        if self.first:
            self.bias_de_q = bias_q/self.weight_scale/self.act_range 
        else :
            self.bias_de_q = bias_q/self.weight_scale/self.act_scale 
        
        output = F.conv_transpose2d(self.x_dequant, weight_fused, self.bias_de_q, self.stride, self.padding,
                        self.dilation, self.groups)
        
        self.output = output
        return output                         
                        
                        
class QConv2d_output(nn.Conv2d):

    def __init__(self,
                 in_channels,
                 out_channels,
                 kernel_size,
                 stride=1,
                 padding=0,
                 dilation=1,
                 groups=1,
                 bias=True,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform',
                 
                 bit_type_act=BIT_TYPE_DICT['uint8'],
                 calibration_mode_act='layer_wise',
                 observer_str_act='minmax',
                 quantizer_str_act='uniform',
                 
                 bit_type_out=BIT_TYPE_DICT['int8'],
                 calibration_mode_out='layer_wise',
                 observer_str_out='minmax',
                 quantizer_str_out='uniform',
                 quant_out = True,
                 
                 QAT = False,
                 first = False,
                 momentum=0.1,
                 eps=1e-6,):
        super(QConv2d_output, self).__init__(
            in_channels=in_channels,
            out_channels=out_channels,
            kernel_size=kernel_size,
            stride=stride,
            padding=padding,
            dilation=dilation,
            groups=groups,
            bias=bias,
        )
        self.quant = quant
        self.quant_out = quant_out
        self.QAT = QAT
        
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str
        
        self.bit_type_act = bit_type_act
        self.calibration_mode_act = calibration_mode_act
        self.observer_str_act = observer_str_act
        self.quantizer_str_act = quantizer_str_act
        
        self.bit_type_out = bit_type_out
        self.calibration_mode_out = calibration_mode_out
        self.observer_str_out = observer_str_out
        self.quantizer_str_out = quantizer_str_out
        
        self.layer_type = 'QConv2d_output'
        self.module_type = 'conv_weight'
        self.module_type_act = 'activation'
        self.module_type_out = 'conv_weight'
        
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        self.observer_act = build_observer(self.observer_str_act, self.module_type_act,
                                       self.bit_type_act, self.calibration_mode_act)
        self.quantizer_act = build_quantizer(self.quantizer_str_act, self.bit_type_act,
                                         self.observer_act, self.module_type_act)
                                         
        #output does not need observer because Qmax Qmin and scale is known value
        #Qmax = 4.599999904632568
        #Qmin = -4.599999904632568
        #scale = (Qmax-Qmin) / (upper_bound-lowerbound)
        #      = (127+127) / (4.599999904632568+4.599999904632568)
        self.out_scale = torch.Tensor([(127.0+127.0) / (4.599999904632568+4.599999904632568)]).cuda()
        self.observer_out = build_observer(self.observer_str_out, self.module_type_out,
                                               self.bit_type_out, self.calibration_mode_out)
        self.quantizer_out = build_quantizer(self.quantizer_str_out, self.bit_type_out,
                                         self.observer_out, self.module_type_out)
        self.quantizer_out.scale = self.out_scale
        self.quantizer_out.zero_point = torch.Tensor([0.0]).cuda()

        
                                         
        #self.observer_bias = build_observer(self.observer_str, self.module_type,
        #                               self.bit_type, 'layer_wise')
        #self.quantizer_bias = build_quantizer(self.quantizer_str, self.bit_type,
        #                                 self.observer_bias, self.module_type)
                                         
                                         
                                         
        #self.weight_scale = torch.nn.Parameter(torch.ones(out_channels)) #channel-wise
        self.weight_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        self.act_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        
        
        #below for QAT
        self.wgt_bit = 8
        self.act_bit = 8
        self.wgt_range=2**(self.wgt_bit-1)-1 #-127~127
        self.act_range=2**(self.act_bit)-1   #0~255
        self.bias_range=(2**15)-1 # -bias_range ~ bias_range   bias 16 bits
        self.wgt_alpha = torch.nn.Parameter(torch.ones(1))  # will update
        #self.wgt_alpha = torch.nn.Parameter(torch.tensor(2823.))
        self.act_alpha = torch.nn.Parameter(torch.ones(1))   # will update
        self.register_buffer('running_max', torch.zeros(1))
        self.register_buffer('running_num', torch.zeros(1))
        
        self.eps = eps
        self.momentum = momentum
        self.gamma = torch.nn.Parameter(torch.ones(out_channels))
        self.beta = torch.nn.Parameter(torch.zeros(out_channels))
        
        self.register_buffer('first_bn', torch.zeros(1))
        self.register_buffer('running_mean', torch.zeros(out_channels))
        self.register_buffer('running_var', torch.ones(out_channels))
        self.first=first
        
        # self.gamma.data.fill_(0.5)
        # self.beta.data.zero_()
        
        # if self.bias is not None:
            # self.bias.data.zero_()
        
        # n = self.kernel_size[0] * self.kernel_size[1] * self.out_channels
        # self.weight.data.normal_(0, math.sqrt(2. / n))   #為何如此/  out_channels


    def sgn(self, x):
        x = RoundWithGradient.apply(x)
        return x
    
    def forward(self, x):
            
        if not self.quant:  #not PTQ
            
            
            if self.QAT :   #QAT part
                weight = self.weight*self.wgt_alpha         
                self.weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                self.weight_q = self.sgn(self.weight_c)
                self.weight_de_q = self.weight_q/self.wgt_alpha 
                
                self.act_reg_QAT = x
                self.input = x
                input = x*self.act_alpha
                input_c = input.clamp(min=0, max=self.act_range)
                self.input_q = self.sgn(input_c)
                self.input_de_q = self.input_q/self.act_alpha
            

                # output=linear_int8(input_q, weight_q, self.bias)
                #self.output1 = F.linear(self.input_de_q, self.weight_de_q, self.bias)  # quantized x and weight  do  int linear
                self.output1 = F.conv2d(self.input_de_q, self.weight_de_q ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                #self.output2 = F.linear(x, self.weight, self.bias)
                self.output2 = F.conv2d(x, self.weight ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                
                
                output = self.output1
                
                return output
            
            
            else :   #baseline part
                
                if self.QAT:  # 以下QAT
                    # Clamp alpha to power of two for making M0=1
                    #self.wgt_alpha.data = self.PoT(self.wgt_alpha)
                    #self.act_alpha.data = self.PoT(self.act_alpha)
                    
                    if self.first:
                        x= x*self.act_range #為何第一層輸入乘上255 ?? 他沒有自己的alpha?  
                    else:
                        x= x*self.act_alpha               #*scale
                    input_c = x.clamp(min=0, max=self.act_range)
                    input_q = self.sgn(input_c)
                    
                    if self.training:
                        weight = weight_batch*self.wgt_alpha     #training 時 weight_batch
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
            
                        if self.first:
                            bias = bias_batch*self.wgt_alpha*self.act_range    # *self.act_range ???
                        else:
                            bias = bias_batch*self.wgt_alpha*self.act_alpha    # *self.act_alpha ???
                        
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        # print(self.wgt_alpha)
                        weight = weight_fused*self.wgt_alpha          #inference  時 weight_fused
                        weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                        weight_q = self.sgn(weight_c)
                        
                        if self.first:
                            bias = bias_fused*self.wgt_alpha*self.act_range   # *self.act_range ???
                        else:
                            bias = bias_fused*self.wgt_alpha*self.act_alpha   # *self.act_alpha ???
                            
                        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
                        bias_q = self.sgn(bias_c)
                        
                        # output = conv2d_int8(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                        output = F.conv2d(input_q, weight_q, bias_q, self.stride, self.padding, self.dilation, self.groups)
                    noise=torch.randn(output.shape).cuda()
                    output=output+self.weight.shape[1]*noise*1    #  self.weight.shape[1]??
        
                    if self.first:
                        output=output/self.act_range/self.wgt_alpha   # /self.act_range ???
                    else:
                        output=output/self.act_alpha/self.wgt_alpha  # /self.act_alpha ???
                else:  # FP training
                    if self.training:
                        input_max=torch.max(x.abs().view(x.shape[0],-1),dim=1)[0]
                        input_max=input_max.mean()
                        
                        with torch.no_grad():
                            if self.running_num==0:
                                self.running_max.add_(input_max)
                                self.running_num.add_(1)
                            else:
                                r=0.1
                                self.running_max.mul_(1-r).add_(input_max*r)
                        self.act_alpha.data=self.act_range/self.running_max.data    #training 時訓練act_alpha?
                        self.wgt_alpha.data=self.wgt_range/self.weight.data.max()  #training 時訓練wgt_alpha?
                        output=F.conv2d(x, self.weight, self.bias, self.stride, self.padding, self.dilation, self.groups)
                    else:
                        self.weight_fused = self.weight
                        self.bias_fused = self.bias
                        self.act_reg = x  #for plot
                        
                        if self.calibrate :
                            self.quantizer.observer.update(self.weight)
                            self.quantizer_act.observer.update(x)
                            if self.observer_str_act =='entropy' :
                                self.input_max_entropy = self.quantizer_act.observer.max_val
                                self.calib_reduce_num  = self.quantizer_act.observer.calib_reduce_num
                                self.input_true_that_time  = self.quantizer_act.observer.input_true_that_time
                                self.input_max_true_that_time  = self.quantizer_act.observer.input_max_true_that_time
                                self.input_max_test  = self.quantizer_act.observer.input_max_test
                                self.input_test  = self.quantizer_act.observer.input_test
                            if self.last_calibrate:
                                #print('quantizer.update_quantization_params')
                                self.quantizer.update_quantization_params(self.weight)
                                self.quantizer_act.update_quantization_params(x)
                                #print('update_quantization scale = {}'.format(self.quantizer.scale))
                        output=F.conv2d(x, self.weight, self.bias, self.stride, self.padding, self.dilation, self.groups)  #inference 時直接用fused?  和162 178行差在哪
                return output
          
         
                #==== new version ====
        # ====PTQ Part
        
        buffer1 = self.quantizer(self.weight)
        #buffer2 = self.quantizer_bias(self.bias)
        self.weight_int = torch.nn.Parameter(torch.zeros(self.weight.size()))
        
        self.weight_original = self.weight
        
        self.weight       = nn.Parameter( buffer1[0] )  
        self.weight_scale = nn.Parameter( buffer1[1] )
        self.weight_int   = nn.Parameter( buffer1[2] )
        #self.bias, self.bias_scale, self.bias_int       = nn.Parameter( self.quantizer(self.bias) )
        # self.bias       = nn.Parameter( buffer2[0] )  
        # self.bias_scale = nn.Parameter( buffer2[1] )
        # self.bias_int   = nn.Parameter( buffer2[2] )
        
        # ====act quant===
        buffer2 = self.quantizer_act(x)
        #buffer2 = self.quantizer_bias(self.bias)
        self.act_int = torch.nn.Parameter(torch.zeros(x.size()))
        
        
        self.x_dequant    = nn.Parameter( buffer2[0] )  
        self.act_scale    = nn.Parameter( buffer2[1] ) #layer-wise
        self.act_int      = nn.Parameter( buffer2[2] )
         
        #x = self.quantizer(x)
        #return self.x_dequant   #fake quantize fp32
        # ====act quant===
        
        self.act_reg = x
        
        if self.first:
            bias = self.bias*self.weight_scale*self.act_range   # *self.act_range ???
        else:
            bias = self.bias*self.weight_scale*self.act_scale   # *self.act_alpha ???
        
        
        
        bias_c = bias.clamp(min=-self.bias_range, max=self.bias_range)
        bias_q = self.sgn(bias_c)
        
        self.bias_fused_quant_int = bias_q
        
        if self.first:
            self.bias_de_q = bias_q/self.weight_scale/self.act_range 
        else :
            self.bias_de_q = bias_q/self.weight_scale/self.act_scale 
        
        output = F.conv2d(self.x_dequant, self.weight, self.bias_de_q, self.stride, self.padding,
                        self.dilation, self.groups)
        
        self.output = output
        
        
        buffer3 = self.quantizer_out(output)
        
        self.out_dequant  = nn.Parameter( buffer3[0] )  
        self.out_scale    = nn.Parameter( buffer3[1] ) #layer-wise
        self.out_int      = nn.Parameter( buffer3[2] )
        
        if self.quant_out:
            # pdb.set_trace()
            return self.out_dequant      
        else:
            return output
                           

class QConvTranspose2d(nn.ConvTranspose2d):

    def __init__(self,
                 in_channels,
                 out_channels,
                 kernel_size,
                 stride=1,
                 padding=0,
                 output_padding=0,
                 dilation=1,
                 groups=1,
                 bias=True,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform',
                 QAT = False ):
        super(QConvTranspose2d, self).__init__(
            in_channels=in_channels,
            out_channels=out_channels,
            kernel_size=kernel_size,
            stride=stride,
            padding=padding,
            output_padding=output_padding,
            dilation=dilation,
            groups=groups,
            bias=bias,
        )
        self.quant = quant
        self.QAT = QAT
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str
      
        
        self.module_type = 'conv_weight'
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        self.weight_scale = torch.nn.Parameter(torch.ones(out_channels)) #channel-wise
        self.weight_int = torch.nn.Parameter(torch.zeros(self.weight.size()))
        
        
        #below for QAT
        self.wgt_bit = 8
        self.act_bit = 8
        self.wgt_range=2**(self.wgt_bit-1)-1 #-127~127
        self.act_range=2**(self.act_bit)-1   #0~255
        self.wgt_alpha = torch.nn.Parameter(torch.ones(1))  # will update
        #self.wgt_alpha = torch.nn.Parameter(torch.tensor(2823.))
        self.act_alpha = torch.nn.Parameter(torch.ones(1))   # will update
        self.register_buffer('running_max', torch.zeros(1))
        self.register_buffer('running_num', torch.zeros(1))
        
    def sgn(self, x):
        x = RoundWithGradient.apply(x)
        return x    
        
    def forward(self, x):
        
        #print('the self.groups of conv_transpose2d  is : {}   type is {} '.format(self.groups,type(self.groups)))
        if self.calibrate:
            self.quantizer.observer.update(self.weight)
            if self.last_calibrate:
                self.quantizer.update_quantization_params(x)
        if not self.quant:  #not PTQ
            if self.QAT :   #QAT part
                weight = self.weight*self.wgt_alpha         
                self.weight_c = weight.clamp(min=-self.wgt_range, max=self.wgt_range)
                self.weight_q = self.sgn(self.weight_c)
                self.weight_de_q = self.weight_q/self.wgt_alpha 
                
                self.act_reg_QAT = x
                self.input = x
                input = x*self.act_alpha
                input_c = input.clamp(min=0, max=self.act_range)
                self.input_q = self.sgn(input_c)
                self.input_de_q = self.input_q/self.act_alpha
            

                # output=linear_int8(input_q, weight_q, self.bias)
                #self.output1 = F.linear(self.input_de_q, self.weight_de_q, self.bias)  # quantized x and weight  do  int linear
                self.output1 = F.conv_transpose2d(self.input_de_q, self.weight_de_q ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                #self.output2 = F.linear(x, self.weight, self.bias)
                self.output2 = F.conv_transpose2d(x, self.weight ,self.bias, self.stride, self.padding, self.dilation, self.groups,)
                
                
                output = self.output1
                
                return output
            
            
            else :   #baseline part
                input_max=x.max()
                self.act_reg_QAT = x
                #self.act_reg = x
                with torch.no_grad():
                    if self.running_num==0:
                        self.running_max.add_(input_max)
                        self.running_num.add_(1)
                        #print('running_max = {}'.format(self.running_max))
                    else:
                        r=0.1
                        self.running_max.mul_(1 - r).add_(input_max*r)
                        #print('running_max = {}'.format(self.running_max))
                        
                self.act_alpha.data=self.act_range/self.running_max.data  #
                self.wgt_alpha.data=self.wgt_range/self.weight.data.max()
                #output=F.linear(x, self.weight, self.bias)
    
                return F.conv_transpose2d(
                    x,
                    self.weight,
                    self.bias,
                    self.stride,
                    self.padding,
                    self.output_padding,
                    #self.dilation,
                    #int(self.groups),
                )
            
            
            
        # PTQ Part
        #self.weight = nn.Parameter( self.quantizer(self.weight))    #weight => self.weight
        
        buffer1 = self.quantizer(self.weight)
        #buffer2 = self.quantizer_bias(self.bias)
        
        self.weight       = nn.Parameter( buffer1[0] )  
        self.weight_scale = nn.Parameter( buffer1[1] )
        self.weight_int   = nn.Parameter( buffer1[2] )
        
        
        
        # return F.conv_transpose2d(x, self.weight, self.bias, self.stride, self.padding, self.output_padding,
                        # self.dilation,int(self.groups))
        return F.conv_transpose2d(x, self.weight, self.bias, self.stride, self.padding, self.output_padding,
                        )
                        
                        
                        
                        
class QLinear(nn.Linear):

    def __init__(self,
                 in_features,
                 out_features,
                 bias=True,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform'):
        super(QLinear, self).__init__(in_features, out_features, bias)

        self.quant = quant
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str

        self.module_type = 'linear_weight'
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)

    def forward(self, x):
        if self.calibrate:
            self.quantizer.observer.update(self.weight)
            if self.last_calibrate:
                self.quantizer.update_quantization_params(x)
        if not self.quant:
            return F.linear(x, self.weight, self.bias)
            
        self.weight = nn.Parameter( self.quantizer(self.weight) ) #weight => self.weight
        return F.linear(x, self.weight, self.bias)


class QAct(nn.Module):

    def __init__(self,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform'):
        super(QAct, self).__init__()

        self.quant = quant
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str

        self.module_type = 'activation'
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)
                                         
        self.act_scale = torch.nn.Parameter(torch.ones(1)) #layer-wise
        #self.act_int = torch.nn.Parameter(torch.zeros(self.weight.size()))

    def forward(self, x):
        if self.calibrate:
            self.quantizer.observer.update(x)
            if self.last_calibrate:
                # import ipdb;ipdb.set_trace()
                self.quantizer.update_quantization_params(x)
        if not self.quant:
            self.act_reg = x  #for plot
            return x
        
        #self.act_reg = x  #for plot
        
        buffer1 = self.quantizer(x)
        #buffer2 = self.quantizer_bias(self.bias)
        self.act_int = torch.nn.Parameter(torch.zeros(x.size()))
        
        
        self.x_dequant    = nn.Parameter( buffer1[0] )  
        self.act_scale    = nn.Parameter( buffer1[1] ) #layer-wise
        self.act_int      = nn.Parameter( buffer1[2] )
         
        #x = self.quantizer(x)
        return self.x_dequant   #fake quantize fp32


class QIntLayerNorm(nn.LayerNorm):

    def __init__(self, normalized_shape, eps=1e-5, elementwise_affine=True):
        super(QIntLayerNorm, self).__init__(normalized_shape, eps,
                                            elementwise_affine)
        assert isinstance(normalized_shape, int)
        self.mode = 'ln'

    def get_MN(self, x):
        bit = 7
        N = torch.clamp(bit - torch.floor(torch.log2(x)), 0, 31)
        M = torch.clamp(torch.floor(x * torch.pow(2, N)), 0, 2**(bit + 1) - 1)
        return M, N

    def forward(self,
                x,
                in_quantizer=None,
                out_quantizer=None,
                in_scale_expand=1):
        if self.mode == 'ln':
            x = F.layer_norm(x, self.normalized_shape, self.weight, self.bias,
                             self.eps)
        elif self.mode == 'int':
            in_scale = in_quantizer.scale
            if in_scale_expand != 1:
                in_scale = in_scale.unsqueeze(-1).expand(
                    -1, in_scale_expand).T.reshape(-1)
            out_scale = out_quantizer.scale
            assert in_scale is not None and out_scale is not None
            channel_nums = x.shape[-1]
            in_scale = in_scale.reshape(1, 1, -1)
            out_scale = out_scale.reshape(1, 1, -1)
            x_q = (x / in_scale).round()
            in_scale1 = in_scale.min()
            in_scale_mask = (in_scale / in_scale1).round()

            x_q = x_q * in_scale_mask

            mean_x_q = x_q.mean(dim=-1) * in_scale1
            std_x_q = (in_scale1 / channel_nums) * torch.sqrt(
                channel_nums * (x_q**2).sum(dim=-1) - x_q.sum(dim=-1)**2)

            A = (in_scale1 / std_x_q).unsqueeze(-1) * \
                self.weight.reshape(1, 1, -1) / out_scale
            A_sign = A.sign()
            M, N = self.get_MN(A.abs())
            B = ((self.bias.reshape(1, 1, -1) -
                  (mean_x_q / std_x_q).unsqueeze(-1) *
                  self.weight.reshape(1, 1, -1)) / out_scale *
                 torch.pow(2, N)).round()

            x_q = ((A_sign * M * x_q + B) / torch.pow(2, N)).round()
            x = x_q * out_scale
        else:
            raise NotImplementedError
        return x


class QIntSoftmax(nn.Module):

    def __init__(self,
                 log_i_softmax=False,
                 quant=False,
                 calibrate=False,
                 last_calibrate=False,
                 bit_type=BIT_TYPE_DICT['int8'],
                 calibration_mode='layer_wise',
                 observer_str='minmax',
                 quantizer_str='uniform'):
        super(QIntSoftmax, self).__init__()

        self.log_i_softmax = log_i_softmax
        self.quant = quant
        self.calibrate = calibrate
        self.last_calibrate = last_calibrate
        self.bit_type = bit_type
        self.calibration_mode = calibration_mode
        self.observer_str = observer_str
        self.quantizer_str = quantizer_str

        self.module_type = 'activation'
        self.observer = build_observer(self.observer_str, self.module_type,
                                       self.bit_type, self.calibration_mode)
        self.quantizer = build_quantizer(self.quantizer_str, self.bit_type,
                                         self.observer, self.module_type)

    @staticmethod
    def log_round(x):
        x_log_floor = x.log2().floor()
        big = x_log_floor
        extra_mask = (x - 2**big) >= 2**(big - 1)
        big[extra_mask] = big[extra_mask] + 1
        return big

    @staticmethod
    def int_softmax(x, scaling_factor):

        def int_polynomial(x_int, scaling_factor):
            coef = [0.35815147, 0.96963238, 1.]  # ax**2 + bx + c
            coef[1] /= coef[0]
            coef[2] /= coef[0]
            b_int = torch.floor(coef[1] / scaling_factor)
            c_int = torch.floor(coef[2] / scaling_factor**2)
            z = x_int + b_int
            z = x_int * z
            z = z + c_int
            scaling_factor = coef[0] * scaling_factor**2
            return z, scaling_factor

        def int_exp(x_int, scaling_factor):
            x0 = -0.6931  # -ln2
            n = 30  # sufficiently large integer
            x0_int = torch.floor(x0 / scaling_factor)
            x_int = torch.max(x_int, n * x0_int)
            q = torch.floor(x_int / x0_int)
            r = x_int - x0_int * q
            exp_int, exp_scaling_factor = int_polynomial(r, scaling_factor)
            exp_int = torch.clamp(torch.floor(exp_int * 2**(n - q)), min=0)
            scaling_factor = exp_scaling_factor / 2**n
            return exp_int, scaling_factor

        x_int = x / scaling_factor
        x_int_max, _ = x_int.max(dim=-1, keepdim=True)
        x_int = x_int - x_int_max
        exp_int, exp_scaling_factor = int_exp(x_int, scaling_factor)
        exp_int_sum = exp_int.sum(dim=-1, keepdim=True)
        return exp_int, exp_int_sum

    def forward(self, x, scale):
        if self.log_i_softmax and scale is not None:
            exp_int, exp_int_sum = self.int_softmax(x, scale)
            softmax_out = torch.round(exp_int_sum / exp_int)
            rounds = self.log_round(softmax_out)
            mask = rounds >= 2**self.bit_type.bits
            qlog = torch.clamp(rounds, 0, 2**self.bit_type.bits - 1)
            deq_softmax = 2**(-qlog)
            deq_softmax[mask] = 0
            return deq_softmax
        else:
            x = x.softmax(dim=-1)
            if self.calibrate:
                self.quantizer.observer.update(x)
                if self.last_calibrate:
                    self.quantizer.update_quantization_params(x)
            if not self.quant:
                return x
            x = self.quantizer(x)
            return x


