import copy
import math
import random
from collections import OrderedDict, defaultdict

from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap
import numpy as np
from tqdm.auto import tqdm

import torch
from torch import nn
from torch.optim import *
from torch.optim.lr_scheduler import *
import torchvision.models as models
import torchvision
from torch.utils.data import DataLoader

from torchvision.datasets import *
from torchvision.transforms import *

from torch.utils.data.sampler import SubsetRandomSampler
from torchvision import datasets
from mobilenet_model.Q_layer import bn_folding_model, bn_folding, fold_conv_bn_eval
from mobilenet_model.Q_layer import get_scale_and_zero_point, linear_quantize
from mobilenet_model.Q_layer import quantized_linear, quantized_conv, do_requant, do_fake_quant,do_dequant
from mobilenet_model.Q_layer import AVP_Fake_Quant,Q_SELayer_deq, Q_SELayer, QuantizedConv, QuantizedLinear, Preprocess, Quantizer

from mobilenet_model.mobilenet_model import SELayer,h_swish,h_sigmoid
from mobilenet_model.mobilenet_model import _make_divisible
from mobilenet_model.mobilenet_model import Our_MobileNetV3,BN_fold_Our_MobileNetV3

from mobilenet_model.golden_gen import bias_gen, signed_dec2hex_matrix, signed_dec2hex, golden_gen, input_or_weight_gen, DecToBin_machine, input_weight_gen_with_0x, \
                                        input_gen_with_0x_dw_ifmap, input_gen_with_0x_pw_ifmap

no_cuda = False
use_gpu = not no_cuda and torch.cuda.is_available()
device = torch.device("cuda" if use_gpu else "cpu")

#transform = transforms.Compose([transforms.ToTensor(), transforms.Normalize((0.5,), (0.5,))])

batch_size = 32

#Dataset
train_dataset = torchvision.datasets.FashionMNIST(root='./data', train=True, transform=transforms.ToTensor(), download=True)
test_dataset = torchvision.datasets.FashionMNIST(root='./data', train=False, transform=transforms.ToTensor(), download=True)

#Dataloader
train_loader = torch.utils.data.DataLoader(dataset=train_dataset, batch_size=batch_size, shuffle=True)
test_loader = torch.utils.data.DataLoader(dataset=test_dataset, batch_size=batch_size, shuffle=False)

Q_Mobilenet_model = torch.load('Mobilenet_ckpt\Quantized_Mobilenet.pt',map_location=device)

# add hook to record the min max value of the activation
q_input_activation = {}
q_output_activation = {}

#Define a hook to record the feature map of each layer
def add_range_recoder_hook(model):
    import functools
    def _record_range(self, x, y, module_name):
        x = x[0]
        q_input_activation[module_name] = x.detach()
        q_output_activation[module_name] = y.detach()

    all_hooks = []
    for name, m in model.named_modules():
        if isinstance(m, (QuantizedConv,  QuantizedLinear,h_swish,Quantizer,Preprocess)):
            all_hooks.append(m.register_forward_hook(
                functools.partial(_record_range, module_name=name)))


    return all_hooks


q_test_loader = torch.utils.data.DataLoader(dataset=test_dataset, batch_size=1, shuffle=False)
hooks = add_range_recoder_hook(Q_Mobilenet_model)
sample_data = iter(q_test_loader).__next__()[0].to(device) #Use a batch of training data to calibrate
Q_Mobilenet_model(sample_data) #Forward to use hook

# remove hooks
for h in hooks:
    h.remove()



loss_fn = nn.CrossEntropyLoss() #define loss function

def test_loop(dataloader, model, loss_fn):
  #set model to evaluate mode
  model.eval()
  size = len(dataloader.dataset)
  num_batches = len(dataloader)
  test_loss, correct = 0, 0
  with torch.no_grad():
    for x, y in dataloader:
      if use_gpu:
        x, y = x.cuda(), y.cuda()
      pred = model(x)
      test_loss = loss_fn(pred, y).item()
      correct += (pred.argmax(1) == y).type(torch.float).sum().item() #calculate accuracy
  test_loss /= num_batches
  correct /= size
  print(f"Test Error: \n Accuracy: {(100*correct):>0.1f}%, Avg loss: {test_loss:>8f} \n")

test_loop(test_loader, Q_Mobilenet_model, loss_fn)

# print(Q_Mobilenet_model.block1[3].weights.shape)
#print(Q_Mobilenet_model.block1[0].weights)
# print(q_input_activation['block1.0'].shape)
# print(q_input_activation['block1.0'])
#input_gen_with_0x_dw_ifmap(q_input_activation['block1.3'])
p2d = (1,1,1,1)
test = golden_layer_decimal = torch.nn.functional.pad(q_input_activation['block1.0'],p2d,"constant",0)
# print("====")
# print(test.shape)
#print(test)
# empty = []
# for matrix in test:
#     for channel_indice,channel in enumerate(matrix):
#         for row_indice,row in enumerate(channel):
#             print(row)

 
print(test)
breakpoint()
batch,channel,rows, cols = test.shape
patches = []
for d in range(channel):
    for i in range(0, rows, 3):
        for j in range(0, cols, 3):
            patch = test[0,d,i:i+3, j:j+3]
            patches.append(patch)
print("=====================")
print(patches)
# byte0,byte1,byte2,byte3 = input_or_weight_gen(q_input_activation['block1.0'])
#bias_gen(Q_Mobilenet_model.block1[3].q_bias)
#input_with_0x = input_weight_gen_with_0x(q_input_activation['block1.0'])
#input_with_0x = input_weight_gen_with_0x(Q_Mobilenet_model.block1[0].weights)
# weight_byte0, weight_byte1, weight_byte2, weight_byte3 = input_or_weight_gen(Q_Mobilenet_model.block1[0].weights)
# golden = golden_gen(q_output_activation['block1.2'])