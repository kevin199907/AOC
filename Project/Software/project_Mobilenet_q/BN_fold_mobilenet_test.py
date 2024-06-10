import copy
import math
import random
from collections import OrderedDict, defaultdict
from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap
import numpy as np
from tqdm.auto import tqdm
import torch.nn.functional as F
import torch
from torch import nn
from torch.optim import *
from torch.optim.lr_scheduler import *
import torchvision.models as models
import torchvision
from torch.utils.data import DataLoader
import torchvision.transforms as transforms
from torchsummary import summary
from torchvision.datasets import *
from torchvision.transforms import *
from torch.utils.data.sampler import SubsetRandomSampler
import torch.optim as optim
from torchvision import datasets

no_cuda = False
use_gpu = not no_cuda and torch.cuda.is_available()
device = torch.device("cuda" if use_gpu else "cpu")

#####
import torch
import torch.nn as nn
import torch.nn.functional as F
import copy

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
#####
def _make_divisible(v, divisor, min_value=None):
    """
    This function is taken from the original tf repo.
    It ensures that all layers have a channel number that is divisible by 8
    It can be seen here:
    https://github.com/tensorflow/models/blob/master/research/slim/nets/mobilenet/mobilenet.py
    :param v:
    :param divisor:
    :param min_value:
    :return:
    """
    if min_value is None:
        min_value = divisor
    new_v = max(min_value, int(v + divisor / 2) // divisor * divisor)
    # Make sure that round down does not go down by more than 10%.
    if new_v < 0.9 * v:
        new_v += divisor
    return new_v

class h_sigmoid(nn.Module):
    def __init__(self, inplace=True):
        super(h_sigmoid, self).__init__()
        self.relu = nn.ReLU6(inplace=inplace)

    def forward(self, x):
        return self.relu(x + 3) / 6


class h_swish(nn.Module):
    def __init__(self, inplace=True):
        super(h_swish, self).__init__()
        self.sigmoid = h_sigmoid(inplace=inplace)

    def forward(self, x):
        return x * self.sigmoid(x)


class SELayer(nn.Module):
    def __init__(self, channel, reduction=4):
        super(SELayer, self).__init__()
        self.avg_pool = nn.AdaptiveAvgPool2d(1)
        self.fc = nn.Sequential(
                nn.Linear(channel, _make_divisible(channel // reduction, 8)),
                nn.ReLU(inplace=True),
                nn.Linear(_make_divisible(channel // reduction, 8), channel),
                h_sigmoid()
        )

    def forward(self, x):
        b, c, _, _ = x.size()
        y = self.avg_pool(x).view(b, c)
        y = self.fc(y).view(b, c, 1, 1)
        return x * y
 

def pw_conv(infp,outfp):
    return nn.Sequential(
        nn.Conv2d(in_channels=infp, out_channels=outfp, kernel_size=1, stride=1,padding= 0, bias=False)
    )

def dw_conv(infp,outfp,kernel_size,stride,padding):
    return nn.Sequential(
        nn.Conv2d(infp,outfp,kernel_size,stride=stride,padding=padding,groups=infp)
    )

class MobileNetV3_block(nn.Module):
    def __init__(self, infp, outfp, middle_feature ,kernel_size,stride,padding,bias=False):
        super(MobileNetV3_block, self).__init__()
        ############ My Design #########
        self.pw1 = nn.Conv2d(in_channels=infp, out_channels=middle_feature, kernel_size=1, stride=1,padding= 0, bias=bias)
        self.bn1 = nn.BatchNorm2d(middle_feature)
        self.hs1 = h_swish()

        self.dw1 = nn.Conv2d(middle_feature,middle_feature,kernel_size,stride=stride,padding=padding,groups=middle_feature, bias=bias)
        self.bn2 = nn.BatchNorm2d(middle_feature)
        self.hs2 = h_swish()
        self.se1 = SELayer(middle_feature)
        self.hs3 = h_swish()
        self.pw2 = nn.Conv2d(in_channels=middle_feature, out_channels=outfp, kernel_size=1, stride=1,padding= 0, bias=bias)
        self.bn3 = nn.BatchNorm2d( outfp)
        self.hs4 = h_swish()
    
    def forward(self,x):
        out = self.pw1(x)
        print(x)
        out = self.bn1(out)
        out = self.hs1(out)
        out = self.dw1(out)
        out = self.bn2(out)
        out = self.hs2(out)
        out = self.se1(out)
        out = self.hs3(out)
        out = self.pw2(out)
        out = self.bn3(out)
        out = self.hs4(out)
        return out
class Our_MobileNetV3_have_bias(nn.Module):
    def __init__(self):
        super(Our_MobileNetV3_have_bias, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1,out_channels=8,kernel_size=3,stride=1,padding=1)
        self.block1 = MobileNetV3_block(infp = 8, outfp=16 , middle_feature=8 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block2 = MobileNetV3_block(infp = 16, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block3 = MobileNetV3_block(infp = 32, outfp=32 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block4 = MobileNetV3_block(infp = 32, outfp=48 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block5 = MobileNetV3_block(infp = 48, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block6 = MobileNetV3_block(infp = 64, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block7 = MobileNetV3_block(infp = 64, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.linear1 = nn.Linear(32,20)
        self.swish = h_swish()
        self.linear2 = nn.Linear(20,10)

    
    def forward(self,x):
        out = self.conv1(x)
        out = self.block1(out)
        out = self.block2(out)
        out = self.block3(out)
        out = self.block4(out)
        out = self.block5(out)
        out = self.block6(out)
        out = self.block7(out)
        out = self.avgpool(out)
        out = out.view(out.size(0),-1)
        out = self.linear1(out)
        out = self.swish(out)
        out = self.linear2(out)
        return out  
####
#from mobilenet_model.mobilenet_model import Our_MobileNetV3_have_bias
from collections import OrderedDict
from mobilenet_model.mobilenet_model import Our_MobileNetV3
from mobilenet_model.mobilenet_model import BN_fold_Our_MobileNetV3

#test = Our_MobileNetV3_have_bias()
#trained_net = Our_MobileNetV3()
trained_net =  Our_MobileNetV3()
have_bias_model = BN_fold_Our_MobileNetV3()
breakpoint()

input_shape = torch.randn(1,1,28,28).cuda()
trained_net_weight = torch.load("N26122246_minist_best.ckpt")
trained_net.load_state_dict(trained_net_weight,strict=False)

origin_net = copy.deepcopy(trained_net)
origin_net = origin_net.cuda()
origin_net.eval()
trained_net = trained_net.cuda()
trained_net.eval()

BN_fold_trained_net=  bn_folding_model(trained_net)

# final_BN_fold_trained_net = BN_fold_Our_MobileNetV3()

#########################################
torch.save(BN_fold_trained_net.state_dict(),"saved_test.ckpt")
have_bias_model_weight =torch.load("saved_test.ckpt")
have_bias_model.load_state_dict(have_bias_model_weight,strict=True)
have_bias_model = have_bias_model.cuda()
have_bias_model.eval()
#########################################
# print(trained_net)
# print("-"*10)
# for name, param in trained_net.named_parameters():
#     print("name:", name)
#     print("param:", param)
# for name, param in BN_fold_trained_net.named_parameters():
#     print("name:", name)
#     print("param:", param)
# print("-"*5)
# for name, param in have_bias_model.named_parameters():
#     print("name:", name)
#     print("param:", param)


# print("pw_weight:",trained_net.block1.pw1.weight)
# print("-"*5)
# print("pw_bias:",trained_net.block1.pw1.bias)
# print("-"*5)
# print("bn_weight:",trained_net.block1.bn1.weight)
# print("-"*5)
# print("bn_bias:",trained_net.block1.bn1.bias)
# print("-"*5)
# print("bn_running_mean:",trained_net.block1.bn1.running_mean)
# print("-"*5)
# print("bn_running_var:",trained_net.block1.bn1.running_var)
# print("-"*5)
# print("bn_running_eps:",trained_net.block1.bn1.eps)
# print("-"*5)
# print("bn_fold_pw1_weight:",BN_fold_trained_net.block1.pw1.weight)
# breakpoint()
# print("-"*5)
# print("bn_fold_pw1_bias:",have_bias_model.block1.pw1.weight)
# print("-"*10)
#print(final_BN_fold_trained_net)


FP32_model = Our_MobileNetV3()
#print(FP32_model)
####
### TODO : You can modify the configuration for model training ###

# For the classification task, we use cross-entropy as the measurement of performance.
criterion = nn.CrossEntropyLoss()

# Initialize optimizer, you may fine-tune some hyperparameters such as learning rate on your own.
optimizer = optim.Adam(have_bias_model.parameters(), lr=0.001)

# The number of batch size.
batch_size = 512

# If no improvement in 'patience' epochs, early stop.
patience  = 10

# The number of training epochs
n_epoch = 100

_exp_name = "N26122246_minist"
####


# Select training_set and testing_set (dataset : FashionMNIST )
train_data = datasets.FashionMNIST("data",train= True, download=True,   transform = transforms.ToTensor())

test_data = datasets.FashionMNIST("data",  train= False, download=True, transform = transforms.ToTensor())

# # Number of subprocesses to use for data loading
# num_workers = 0

# Percentage of training set to use as validation
n_valid = 0.2

# Get indices for training_set and validation_set
n_train = len(train_data)
indices = list(range(n_train))
np.random.shuffle(indices)
#split = 1
split = int(np.floor(n_valid * n_train))
train_idx, valid_idx = indices[split:], indices[:split]

# Define samplers for obtaining training and validation
train_sampler = SubsetRandomSampler(train_idx)
valid_sampler = SubsetRandomSampler(valid_idx)
####
# Training data
trainset = torchvision.datasets.FashionMNIST(root='./data', train=True, download=True, transform=transforms.ToTensor())
trainloader = torch.utils.data.DataLoader(trainset, batch_size=batch_size,  sampler = train_sampler , num_workers=2)

# Validation data
validloader = torch.utils.data.DataLoader(trainset, batch_size = batch_size, sampler = valid_sampler, num_workers = 2)

# Test data
testset = torchvision.datasets.FashionMNIST(root='./data', train=False, download=True, transform=transforms.ToTensor())
testloader = torch.utils.data.DataLoader(testset, batch_size=batch_size,  num_workers=2)

####
correct = 0
total = 0
# since we're not training, we don't need to calculate the gradients for our outputs
with torch.no_grad():
    for data in testloader:
        images, labels = data
        if use_gpu:
            images, labels = images.cuda(),labels.cuda()
        # calculate outputs by running images through the network
        #outputs = trained_net(images)
        outputs = have_bias_model(images)
        # the class with the highest energy is what we choose as prediction
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

print(f'Accuracy of the network on the 10000 test images: {100 * correct // total} %')