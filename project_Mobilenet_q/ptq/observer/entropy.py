# Copyright (c) MEGVII Inc. and its affiliates. All Rights Reserved.
import torch
import numpy as np
from .base import BaseObserver
from collections import Counter
from scipy.stats import entropy

class EntropyObserver(BaseObserver):

    def __init__(self, module_type, bit_type, calibration_mode, first=False):
        super(EntropyObserver, self).__init__(module_type, bit_type,
                                             calibration_mode, first)
        self.symmetric = self.bit_type.signed
        self.first = first
        #self.register_buffer('running_max', torch.zeros(1))
        #self.register_buffer('running_num', torch.zeros(1))
        self.best_score = 1e+10 
        
    def update(self, v):
        # v = self.reshape_tensor(v)
        # cur_max = v.max(axis=1).values
        # if self.max_val is None:
            # self.max_val = cur_max                                  #channel wise
        # else:
            # self.max_val = torch.max(cur_max, self.max_val)
        # cur_min = v.min(axis=1).values
        # if self.min_val is None:
            # self.min_val = cur_min                         
        # else:
            # self.min_val = torch.min(cur_min, self.min_val)         #layer wise

        # if self.calibration_mode == 'layer_wise':
            # self.max_val = self.max_val.max()
            # self.min_val = self.min_val.min()

        self.input_max_test = v.max()
        self.input_test     = v
        
        self.input_max_entropy , self.min_divergences , calib_reduce_num = self.To_histogram_get_entropy_amax(v, bins = 2048 , bits = self.bit_type.bits )
        
        # with torch.no_grad():
            # if self.running_num==0:
                # self.running_max.add_(input_max_entropy)
                # self.running_num.add_(1)
                # #print('running_max = {}'.format(self.running_max))
            # else:
                # r=0.1
                # self.running_max.mul_(1 - r).add_(input_max_entropy*r)
                # #print('running_max = {}'.format(self.running_max)) 
          
        if self.min_divergences < self.best_score:
            self.best_score = self.min_divergences
            self.max_val = self.input_max_entropy
            self.min_val = v.min()
            self.input_true_that_time = v
            self.input_max_true_that_time = v.max()
            self.calib_reduce_num = calib_reduce_num
            
                
        

    def get_quantization_params(self, *args, **kwargs):
        max_val = self.max_val
        min_val = self.min_val
        one = torch.tensor(1).cuda() 
        
        qmax = self.bit_type.upper_bound
        qmin = self.bit_type.lower_bound

        scale = torch.ones_like(max_val, dtype=torch.float32).cuda()       #scale = FP32  #probabliy channel wise or layer wise
        zero_point = torch.zeros_like(max_val, dtype=torch.int64).cuda()   #zero_point = int 64
        
        
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
        
        
        
    def To_histogram_get_entropy_amax(self, x , bins = 2048 ,  bits = 8):
        x_max = x.max()
        calib_hist = torch.histc(x, bins = bins , min=0, max = x_max)
        calib_bin_edges = torch.linspace(0, x_max, bins + 1)
        
        bins = calib_hist[:]
        bins[0] = bins[1]
        total_data = torch.sum(bins)
        divergences = []
        arguments = []
        reduce_num = []
        num_bits = bits
        start_bin = 128
        
        stride = 1
        
        # we are quantizing to 128 values + sign if num_bits=8
        unsigned = True
        nbins = 1 << (num_bits - 1 + int(unsigned))
    
    
        starting = start_bin  #128
        stop = len(bins)
        bins = bins.cpu().detach().numpy()
        
        new_density_counts = np.zeros(nbins, dtype=np.float64)
    
    
    
        for i in range(starting, stop + 1, stride):  # bin 128 ~ 2048   挑看要在哪個bin 才是最佳的
            new_density_counts.fill(0)
            space = np.linspace(0, i, num=nbins + 1)  # 0~ bin i  分成 256份
            digitized_space = np.digitize(range(i), space) - 1# digitized_space 是新取的範圍個數  內容是 舊bins(range(i)) 對應新bins 的index
            #breakpoint()
            digitized_space[bins[:i] == 0] = -1
    
            for idx, digitized in enumerate(digitized_space):
                if digitized != -1:
                    new_density_counts[digitized] += bins[idx]  #算出新取的範圍 bins_new 的每個個數
    
            counter = Counter(digitized_space)
            for key, val in counter.items():
                if key != -1:
                    new_density_counts[key] = new_density_counts[key] / val
    
            new_density = np.zeros(i, dtype=np.float64)
            for idx, digitized in enumerate(digitized_space):
                if digitized != -1:
                    new_density[idx] = new_density_counts[digitized]
                    #breakpoint()
    
            total_counts_new = np.sum(new_density) + np.sum(bins[i:])
            reduce_num_count = total_data - np.sum(new_density)
            
            new_density = self._normalize_distr(new_density)  ##
    
            reference_density = np.array(bins[:len(digitized_space)])
            reference_density[-1] += np.sum(bins[i:])  
    
            total_counts_old = np.sum(reference_density)
            if round(total_counts_new) != total_data or round(total_counts_old) != total_data:
                raise RuntimeError("Count mismatch! total_counts_new={}, total_counts_old={}, total_data={}".format(
                    total_counts_new, total_counts_old, total_data))
    
            reference_density = self._normalize_distr(reference_density) ##
    
            ent = entropy(reference_density, new_density)
            
            #print(f'ent = {ent}')
            #breakpoint()
            
            divergences.append(ent)
            arguments.append(i)
            reduce_num.append(reduce_num_count)
            #print(f'len(divergences) is {len(divergences)}')
    
    
    
        diergences = np.array(divergences)
        #logging.debug("divergences={}".format(divergences))
        last_argmin = len(divergences) - 1 - np.argmin(divergences[::-1])  # ??????????????????????
        #print(f'len(divergences) is {len(divergences)}')
        #print(f'np.argmin(divergences[::-1] is {np.argmin(divergences[::-1])}')
        #print(f'min  divergences is {(divergences[len(divergences) - 1 - np.argmin(divergences[::-1])] )  }')
        
        #print(f'last_argmin is {last_argmin+ starting}')
        
        
        calib_amax = calib_bin_edges[last_argmin * stride + starting]
        calib_reduce_num = reduce_num[last_argmin * stride]
        #print(f'calib_amax is {calib_amax}')
        calib_amax = torch.tensor(calib_amax.item()).cuda() #pylint: disable=not-callable
        calib_reduce_num = torch.tensor(calib_reduce_num.item()).cuda()
        
        min_divergences = min(divergences) 
        #print(f'calib_amax is {calib_amax}')
        #print(f'x_max = {x_max}')
        
        return calib_amax ,min_divergences, calib_reduce_num
    
    
    
    
    def _normalize_distr(self, distr):
        summ = np.sum(distr)
        if summ != 0:
            distr = distr / summ
        return distr

