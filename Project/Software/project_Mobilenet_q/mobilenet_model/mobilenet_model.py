import torch
import torch.nn as nn
import torch.nn.functional as F
import torchvision
import torchvision.transforms as transforms
from torchsummary import summary
import torch.optim as optim
from torchvision import datasets
from tqdm import tqdm
import numpy as np
from torch.utils.data.sampler import SubsetRandomSampler
import math

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

        out1 = self.pw1(x)
        out2 = self.bn1(out1)
        out3 = self.hs1(out2)
        out4 = self.dw1(out3)
        out5 = self.bn2(out4)
        out6 = self.hs2(out5)
        out7 = self.se1(out6)
        out8 = self.hs3(out7)
        out9 = self.pw2(out8)
        out10 = self.bn3(out9)
        out11 = self.hs4(out10)
        self.input_pw_bn1_out = out2
        #breakpoint()
        return out11
        

class Our_MobileNetV3(nn.Module):
    def __init__(self):
        super(Our_MobileNetV3, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1,out_channels=8,kernel_size=3,stride=1,padding=1,bias=False)
        self.block1 = MobileNetV3_block(infp = 8, outfp=16 , middle_feature=8 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block2 = MobileNetV3_block(infp = 16, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block3 = MobileNetV3_block(infp = 32, outfp=32 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block4 = MobileNetV3_block(infp = 32, outfp=48 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block5 = MobileNetV3_block(infp = 48, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block6 = MobileNetV3_block(infp = 64, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.block7 = MobileNetV3_block(infp = 64, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=False)
        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.linear1 = nn.Linear(32,20,bias=False)
        self.swish = h_swish()
        self.linear2 = nn.Linear(20,10,bias=False)

    
    def forward(self,x):
        out1 = self.conv1(x)
        out2 = self.block1(out1)
        out3 = self.block2(out2)
        out4 = self.block3(out3)
        out5 = self.block4(out4)
        out6 = self.block5(out5)
        out7 = self.block6(out6)
        out8 = self.block7(out7)
        out = self.avgpool(out8)
        out = out.view(out.size(0),-1)
        out = self.linear1(out)
        out = self.swish(out)
        out = self.linear2(out)
        #breakpoint()
        return out
########################################
class Our_MobileNetV3_have_bias(nn.Module):
    def __init__(self):
        super(Our_MobileNetV3_have_bias, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1,out_channels=8,kernel_size=3,stride=1,padding=1,bias=False)
        self.block1 = MobileNetV3_block(infp = 8, outfp=16 , middle_feature=8 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block2 = MobileNetV3_block(infp = 16, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block3 = MobileNetV3_block(infp = 32, outfp=32 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block4 = MobileNetV3_block(infp = 32, outfp=48 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block5 = MobileNetV3_block(infp = 48, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block6 = MobileNetV3_block(infp = 64, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block7 = MobileNetV3_block(infp = 64, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.linear1 = nn.Linear(32,20,bias=False)
        self.swish = h_swish()
        self.linear2 = nn.Linear(20,10,bias=False)

    
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

########################################
    
class BN_fold_MobileNetV3_block(nn.Module):
    def __init__(self, infp, outfp, middle_feature ,kernel_size,stride,padding,bias):
        super(BN_fold_MobileNetV3_block, self).__init__()

        ############ My Design #########

        self.pw1 = nn.Conv2d(in_channels=infp, out_channels=middle_feature, kernel_size=1, stride=1,padding= 0, bias=bias)
        self.hs1 = h_swish()

        self.dw1 = nn.Conv2d(middle_feature,middle_feature,kernel_size,stride=stride,padding=padding,groups=middle_feature,bias=bias)

        self.hs2 = h_swish()
        self.se1 = SELayer(middle_feature)
        self.hs3 = h_swish()
        self.pw2 = nn.Conv2d(in_channels=middle_feature, out_channels=outfp, kernel_size=1, stride=1,padding= 0, bias=bias)
        self.hs4 = h_swish()
    
    def forward(self,x):
        
        out1 = self.pw1(x)
        out2 = self.hs1(out1)
        out3 = self.dw1(out2)
        out4 = self.hs2(out3)
        out5 = self.se1(out4)
        out6 = self.hs3(out5)
        out7 = self.pw2(out6)
        out8 = self.hs4(out7)
        self.bn_fold_pw1_out = out1
        #breakpoint()
        return out8

  
class BN_fold_Our_MobileNetV3(nn.Module):
    def __init__(self):
        super(BN_fold_Our_MobileNetV3, self).__init__()
        self.conv1 = nn.Conv2d(in_channels=1,out_channels=8,kernel_size=3,stride=1,padding=1,bias=False)
        self.block1 = BN_fold_MobileNetV3_block(infp = 8, outfp=16 , middle_feature=8 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block2 = BN_fold_MobileNetV3_block(infp = 16, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block3 = BN_fold_MobileNetV3_block(infp = 32, outfp=32 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block4 = BN_fold_MobileNetV3_block(infp = 32, outfp=48 , middle_feature=64 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block5 = BN_fold_MobileNetV3_block(infp = 48, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block6 = BN_fold_MobileNetV3_block(infp = 64, outfp=64 , middle_feature=96 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.block7 = BN_fold_MobileNetV3_block(infp = 64, outfp=32 , middle_feature=48 ,kernel_size=3,stride=2,padding=1,bias=True)
        self.avgpool = nn.AdaptiveAvgPool2d(1)
        self.linear1 = nn.Linear(32,20,bias=False)
        self.swish = h_swish()
        self.linear2 = nn.Linear(20,10,bias=False)

    
    def forward(self,x):
        out1 = self.conv1(x)
        out2 = self.block1(out1)
        out3 = self.block2(out2)
        out4 = self.block3(out3)
        out5 = self.block4(out4)
        out6 = self.block5(out5)
        out7 = self.block6(out6)
        out8 = self.block7(out7)
        out = self.avgpool(out8)
        out = out.view(out.size(0),-1)
        out = self.linear1(out)
        out = self.swish(out)
        out = self.linear2(out)
       # breakpoint()
        return out
