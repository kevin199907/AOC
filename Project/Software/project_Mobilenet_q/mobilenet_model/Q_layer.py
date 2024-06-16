import copy
import math
import random
from collections import OrderedDict, defaultdict
import copy
from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap
import numpy as np
from tqdm.auto import tqdm

import torch
from torch import nn
import torch.nn.functional as F
from torch.optim import *
from torch.optim.lr_scheduler import *
import torchvision.models as models
import torchvision
from torch.utils.data import DataLoader

from torchvision.datasets import *
from torchvision.transforms import *

# from mobilenet_model import _make_divisible
# from mobilenet_model import h_sigmoid, h_swish, SELayer


no_cuda = False
use_gpu = not no_cuda and torch.cuda.is_available()
device = torch.device("cuda" if use_gpu else "cpu")

############# below is BN_FOLD ##################
def bn_folding_model(model):

    new_model = copy.deepcopy(model)

    module_names = list(new_model._modules)

    for k, name in enumerate(module_names):
        if len(list(new_model._modules[name]._modules)) > 0:
            new_model._modules[name] = bn_folding_model(new_model._modules[name])

            
        else:
            if isinstance(new_model._modules[name], nn.BatchNorm2d):
                if isinstance(new_model._modules[module_names[k-1]], nn.Conv2d):

                    # Folded BN
                    folded_conv = fold_conv_bn_eval(new_model._modules[module_names[k-1]], new_model._modules[name])

                    # Replace old weight values
                    new_model._modules.pop(name) # Remove the BN layer
                    new_model._modules[module_names[k-1]] = folded_conv # Replace the Convolutional Layer by the folded version
    return new_model



def bn_folding(conv_w, conv_b, bn_rm, bn_rv, bn_eps, bn_w, bn_b):
    if conv_b is None:
        conv_b = bn_rm.new_zeros(bn_rm.shape)
    bn_var_rsqrt = torch.rsqrt(bn_rv + bn_eps)

    w_fold = conv_w * (bn_w * bn_var_rsqrt).view(-1, 1, 1, 1)
    b_fold = (conv_b - bn_rm) * bn_var_rsqrt * bn_w + bn_b
    
    return torch.nn.Parameter(w_fold), torch.nn.Parameter(b_fold)


def fold_conv_bn_eval(conv, bn):
    assert(not (conv.training or bn.training)), "Fusion only for eval!"
    fused_conv = copy.deepcopy(conv)

    fused_conv.weight, fused_conv.bias = bn_folding(fused_conv.weight, fused_conv.bias,
                             bn.running_mean, bn.running_var, bn.eps, bn.weight, bn.bias)

    return fused_conv

############# below is Quantization ##################
def get_scale_and_zero_point(fp32_tensor, bitwidth=8):
  q_min, q_max = -(2**(bitwidth-1)-1), 2**(bitwidth-1) - 1
  fp_min = fp32_tensor.min().item()
  fp_max = fp32_tensor.max().item()

  #####################################################

  scale = (fp_max-fp_min) / (q_max-q_min)
  zero_point = q_min-fp_min /scale

  #####################################################


  zero_point = round(zero_point)          #round
  zero_point = max(q_min, min(zero_point, q_max)) #clip

  return scale, int(zero_point)

def linear_quantize(fp32_tensor, bitwidth=8):
  q_min, q_max = -(2**(bitwidth-1)-1), 2**(bitwidth-1) - 1

  scale, zero_point = get_scale_and_zero_point(fp32_tensor)

  #####################################################

  q_tensor = torch.round( fp32_tensor/scale ) +zero_point

  #####################################################

  #clamp
  q_tensor = torch.clamp(q_tensor, q_min, q_max)
  return q_tensor, scale, zero_point  

def quantized_linear(input, weights, input_scale, weight_scale, output_scale, input_zero_point, weight_zero_point, output_zero_point, device, bitwidth=8, activation_bitwidth=8):
  input, weights = input.to(device), weights.to(device)

  #####################################################

  M = input_scale * weight_scale / output_scale
  output = torch.nn.functional.linear((input - input_zero_point ), (weights - weight_zero_point))
  output *= M
  output += output_zero_point

  #####################################################

  #clamp and round
  output = output.round().clamp(-(2**(activation_bitwidth-1)-1), 2**(activation_bitwidth-1)-1)

  return output

def quantized_conv(input, bias,weights,stride, padding,groups,input_scale, weight_scale, output_scale, input_zero_point, weight_zero_point, output_zero_point, device, bitwidth=8, activation_bitwidth=16):
  input, weights, bias = input.to(device), weights.to(device) , bias.to(device)

  #####################################################

  M = input_scale * weight_scale 
  conv_bias = bias /M
  conv_bias = conv_bias.round()
  output_only_conv = torch.nn.functional.conv2d((input - input_zero_point ), (weights - weight_zero_point),bias = conv_bias ,stride=stride,padding=padding,groups=groups)
  output = M * output_only_conv
  #output += output_zero_point

  #####################################################

  #clamp and round
  output = output.clamp(-(2**(activation_bitwidth-1)-1), 2**(activation_bitwidth-1)-1)

  return output

def do_requant(input, scale,zero_point,bitwidth=8):
    output = input / scale
    output = output.round()
    output += zero_point
    output = output.round().clamp(-(2**(bitwidth-1)-1), 2**(bitwidth-1)-1)
    return output

def do_fake_quant(input, deq_scale, q_scale, q_zero_point,bitwidth=8):
    M = deq_scale/q_scale
    N = q_zero_point
    output = input * M
    output += N
    output = output.round().clamp(-(2**(bitwidth-1)-1), 2**(bitwidth-1)-1)
    return output


class QuantizedConv(nn.Module):
  def __init__(self,bias ,weights,stride,padding,groups ,input_scale, weight_scale, output_scale, input_zero_point, weight_zero_point, output_zero_point, bitwidth=8, activation_bitwidth=8):
    super().__init__()
    self.stride, self.padding, self.groups = stride, padding,groups
    self.weights = weights
    self.input_scale, self.input_zero_point = input_scale, input_zero_point
    self.weight_scale, self.weight_zero_point = weight_scale, weight_zero_point
    self.output_scale, self.output_zero_point = output_scale, output_zero_point
    self.bias = bias
    self.bitwidth = bitwidth
    self.activation_bitwidth = activation_bitwidth
    self.q_bias = torch.round(bias / (input_scale*weight_scale))
    self.q_weight = weights - weight_zero_point
    self.DeQ_scale = input_scale*weight_scale
  def forward(self, x):
    return quantized_conv(x, self.bias, self.weights, self.stride, self.padding, self.groups, self.input_scale, self.weight_scale, self.output_scale, self.input_zero_point, self.weight_zero_point, self.output_zero_point, device)
  def __repr__(self):
    return f"QuantizedConv(in_channels={self.weights.size(1)}, out_channels={self.weights.size(0)})"

class QuantizedLinear(nn.Module):
  def __init__(self, weights, input_scale, weight_scale, output_scale, input_zero_point, weight_zero_point, output_zero_point, bitwidth=8, activation_bitwidth=8):
    super().__init__()
    self.weights = weights
    self.input_scale, self.input_zero_point = input_scale, input_zero_point
    self.weight_scale, self.weight_zero_point = weight_scale, weight_zero_point
    self.output_scale, self.output_zero_point = output_scale, output_zero_point

    self.bitwidth = bitwidth
    self.activation_bitwidth = activation_bitwidth

  def forward(self, x):
    return quantized_linear(x, self.weights, self.input_scale, self.weight_scale, self.output_scale, self.input_zero_point, self.weight_zero_point, self.output_zero_point, device)
  def __repr__(self):
    return f"QuantizedLinear(in_channels={self.weights.size(1)}, out_channels={self.weights.size(0)})"

#Transform input data to correct integer range
class Preprocess(nn.Module):
  def __init__(self, input_scale, input_zero_point, activation_bitwidth=8):
    super().__init__()
    self.input_scale, self.input_zero_point = input_scale, input_zero_point
    self.activation_bitwidth = activation_bitwidth
  def forward(self, x):
    x = x / self.input_scale + self.input_zero_point
    x = x.round() 
    return x
  
class Quantizer(nn.Module):
  def __init__(self,scale,zero_point,bitwidth=8):
    super().__init__()
    self.scale = scale
    self.zero = zero_point
    self.store_scale = scale *64

  def forward(self,x):
    return do_requant(x,self.scale,self.zero)
    


def do_dequant(input, deq_scale, q_scale, q_zero_point,bitwidth=8):
    M = deq_scale
    N = q_zero_point
    output = input * M
    output += N
    output = output.clamp(-(2**(bitwidth-1)-1), 2**(bitwidth-1)-1)
    return output


class Q_SELayer(nn.Module):
  def __init__(self,weights1,input_scale1,weight_scale1,output_scale1, input_zero_point1, weight_zero_point1, output_zero_point1,
               weights2, input_scale2, weight_scale2, output_scale2, input_zero_point2, weight_zero_point2, output_zero_point2,
               input_SE_scale,in_SE_zero_point,
               output_SE_scale,output_SE_zero_point,
               out_pool_scale,out_pool_zero_point):
    super().__init__()
    self.avg_pool = nn.AdaptiveAvgPool2d(1)
    self.fc = nn.Sequential(
        QuantizedLinear(weights1,input_scale1,weight_scale1,output_scale1, input_zero_point1, weight_zero_point1, output_zero_point1),
        QuantizedLinear(weights2, input_scale2, weight_scale2, output_scale2, input_zero_point2, weight_zero_point2, output_zero_point2)
    )   
    self.input_SE_scale, self.in_SE_zero_point = input_SE_scale,in_SE_zero_point
    self.output_SE_scale, self.output_SE_zero_point = output_SE_scale, output_SE_zero_point,
    self.out_pool_scale, self.out_pool_zero_point = out_pool_scale,out_pool_zero_point
    self.linear_out_scale, self.linear_out_zero_point = output_scale2, output_zero_point2


  def forward(self,x):
    b, c, _, _ = x.size()
    y = self.avg_pool(x).view(b, c)
    y = (y- self.in_SE_zero_point) 
    y = do_fake_quant(y, self.input_SE_scale, self.out_pool_scale, self.out_pool_zero_point,bitwidth=8)
    y = self.fc(y).view(b, c, 1, 1)
    z = (x-self.in_SE_zero_point)*(y-self.linear_out_zero_point)
    return do_fake_quant(z, deq_scale=(self.input_SE_scale *self.linear_out_scale), 
                         q_scale=self.output_SE_scale, q_zero_point=self.output_SE_zero_point,bitwidth=8)
  
  def __repr__(self):
    return f"Quantized_SE(in_channels={self.fc[0].weights.size(1)}, out_channels={self.fc[1].weights.size(0)})"
    


class Q_SELayer_deq(nn.Module):
  def __init__(self,weights1,input_scale1,weight_scale1,output_scale1, input_zero_point1, weight_zero_point1, output_zero_point1,
               weights2, input_scale2, weight_scale2, output_scale2, input_zero_point2, weight_zero_point2, output_zero_point2,
               input_SE_scale,in_SE_zero_point,
               output_SE_scale,output_SE_zero_point,
               out_pool_scale,out_pool_zero_point):
    super().__init__()
    self.avg_pool = nn.AdaptiveAvgPool2d(1)
    self.fc = nn.Sequential(
        QuantizedLinear(weights1,input_scale1,weight_scale1,output_scale1, input_zero_point1, weight_zero_point1, output_zero_point1),
        QuantizedLinear(weights2, input_scale2, weight_scale2, output_scale2, input_zero_point2, weight_zero_point2, output_zero_point2)
    )   
    self.input_SE_scale, self.in_SE_zero_point = input_SE_scale,in_SE_zero_point
    self.output_SE_scale, self.output_SE_zero_point = output_SE_scale, output_SE_zero_point,
    self.out_pool_scale, self.out_pool_zero_point = out_pool_scale,out_pool_zero_point
    self.linear_out_scale, self.linear_out_zero_point = output_scale2, output_zero_point2


  def forward(self,x):
    b, c, _, _ = x.size()
    y = self.avg_pool(x).view(b, c)
    y = (y- self.in_SE_zero_point) 
    y = do_fake_quant(y, self.input_SE_scale, self.out_pool_scale, self.out_pool_zero_point,bitwidth=8)
    y = self.fc(y).view(b, c, 1, 1)
    z = (x-self.in_SE_zero_point)*(y-self.linear_out_zero_point)
    return do_dequant(z, deq_scale=(self.input_SE_scale *self.linear_out_scale), 
                         q_scale=self.output_SE_scale, q_zero_point=self.output_SE_zero_point,bitwidth=8)
  
  def __repr__(self):
    return f"Quantized_SE_deq(in_channels={self.fc[0].weights.size(1)}, out_channels={self.fc[1].weights.size(0)})"
    

class AVP_Fake_Quant(nn.Module):
   def __init__(self,input_scale,output_scale,input_zero_point,output_zero_point):
      super().__init__()
      self.avp = nn.AdaptiveAvgPool2d(1)
      self.input_scale = input_scale
      self.input_zero_point = input_zero_point
      self.output_scale = output_scale
      self.output_zero_point = output_zero_point
   def forward(self,x):
      x = self.avp(x)
      x = x - self.input_zero_point
      return do_fake_quant(x,self.input_scale,self.output_scale,self.output_zero_point)
