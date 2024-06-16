import torch
from torch import nn
import numpy as np
def signed_dec2hex_matrix_16b(input):
    '''Convert a matrix which data is signed decimal to 8 bits hex with 2's complement'''
    temp = []
    bin8 = lambda x : ''.join(reversed( [str((x >> i) & 1) for i in range(16)] ) )
    for i in input:
        test =bin8(i)
        test = int(test,base=2)
        hex_test = hex(test)[2:].zfill(2)
        temp.append(hex_test)

    return temp

def signed_dec2hex_16b(input):
    '''Convert a number which data is signed decimal to 8 bits hex with 2's complement'''
    bin8 = lambda x : ''.join(reversed( [str((x >> i) & 1) for i in range(16)] ) )
    test =bin8(input)
    test = int(test,base=2)
    hex_test = hex(test)[2:].zfill(2)

    return hex_test

def signed_dec2hex_matrix(input):
    '''Convert a matrix which data is signed decimal to 8 bits hex with 2's complement'''
    temp = []
    bin8 = lambda x : ''.join(reversed( [str((x >> i) & 1) for i in range(8)] ) )
    for i in input:
        test =bin8(i)
        test = int(test,base=2)
        hex_test = hex(test)[2:].zfill(2)
        temp.append(hex_test)

    return temp

def signed_dec2hex(input):
    '''Convert a number which data is signed decimal to 8 bits hex with 2's complement'''
    bin8 = lambda x : ''.join(reversed( [str((x >> i) & 1) for i in range(8)] ) )
    test =bin8(input)
    test = int(test,base=2)
    hex_test = hex(test)[2:].zfill(2)

    return hex_test


def golden_gen(golden_layer_decimal):
    '''Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make it 4 element in a line, example of use : golden_gen(q_output_activation["Conv.3"]) '''
    golden = []
    i=0
    golden_in_numpy = golden_layer_decimal.cpu().numpy()
    test = golden_in_numpy.flatten()
    test =test.astype('int32')
    golden.append([])
    for j, data in enumerate(test):
        if(j%4==0 ):
            golden.append([])
            i = i+1
            golden[i].append(signed_dec2hex(data))
        if(j%4!=0):
            golden[i].append(signed_dec2hex(data))
    golden.pop(0)
    for indice,data in enumerate(golden):
        print(*data,sep='')
    return golden

def input_or_weight_gen(layer_decimal):
    '''Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make each byte display in different place, example of use : input_or_weight_gen(quantized_model.Conv[1].weights)'''
    byte0 = []
    byte1 = []
    byte2 = []
    byte3 = []

    data_in_numpy = layer_decimal.cpu().numpy()
    data_test = data_in_numpy.flatten()
    data_test = data_test.astype('int32')
    data_test = signed_dec2hex_matrix(data_test)
    for indice,data in enumerate(data_test):
        if(indice%4 == 0):
            byte0.append(data)
        elif(indice%4 == 1):
            byte1.append(data)
        elif(indice%4 == 2):
            byte2.append(data)
        else:
            byte3.append(data)
    print("byte0:",*byte0)
    print("=======")
    print("byte1:",*byte1)
    print("=======")
    print("byte2:",*byte2)
    print("=======")
    print("byte3:",*byte3)
    print("=======")
    return byte0,byte1,byte2,byte3

def bias_gen(layer_decimal):
    '''Generate bias, because bias is 16bits, it need to do it using different way'''
    byte0 = []
    byte1 = []
    byte2 = []
    byte3 = []
    temp1 = []

    data_in_numpy = layer_decimal.cpu().numpy()
    data_test = data_in_numpy.flatten()
    data_test = data_test.astype('int32')
    data_test = signed_dec2hex_matrix_16b(data_test)
    for indice,data in enumerate(data_test):
        if(indice%2 == 0):
            if(len(data)==1):
                byte1.append('00')
                byte0.append('0'+str(data))
            elif(len(data)==2):
                byte1.append('00')
                byte0.append(data)
            elif(len(data)==3):
                temp = data[2]
                byte1.append('0'+data[0])
                byte0.append(data[1]+data[2])
            elif(len(data)==4):
                byte1.append(data[0:2])
                byte0.append(data[2:4])
        elif(indice%2 == 1):
            if(len(data)==1):
                byte3.append('00')
                byte2.append('0'+str(data))
            elif(len(data)==2):
                byte3.append('00')
                byte2.append(data)
            elif(len(data)==3):
                byte3.append('0'+data[0])
                byte2.append(data[1]+data[2])
            elif(len(data)==4):
                byte3.append(data[0:2])
                byte2.append(data[2:4])

    print("byte0:",*byte0)
    print("=======")
    print("byte1:",*byte1)
    print("=======")
    print("byte2:",*byte2)
    print("=======")
    print("byte3:",*byte3)
    print("=======")
    return byte0,byte1,byte2,byte3

def DecToBin_machine(num,accuracy):
    integer = int(num)
    flo = num - integer
    integercom = '{:1b}'.format(integer)
    tem = flo
    flo_list = []
    for i in range(accuracy):
        tem *= 2
        flo_list += str(int(tem))
        tem -= int(tem)
    flocom = flo_list
    binary_value =  ''.join(flocom)
    return binary_value

def input_weight_gen_with_0x(golden_layer_decimal):
    '''Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make it 4 element in a line, example of use : golden_gen(q_output_activation["Conv.3"]) '''
    golden = []
    i=0
    golden_in_numpy = golden_layer_decimal.cpu().numpy()
    test = golden_in_numpy.flatten()
    test =test.astype('int32')
    golden.append([])
    for j, data in enumerate(test):
        if(j%4==0 ):
            golden.append([])
            i = i+1
            golden[i].append(signed_dec2hex(data))
        if(j%4!=0):
            golden[i].append(signed_dec2hex(data))
    golden.pop(0)
    temp = '0x'
    temp1 = ',\\'
    for indice,data in enumerate(golden):
        golden[indice].insert(0,temp)
        golden[indice].append(temp1)

    for indice,data in enumerate(golden):
        print(*data,sep='')
    return golden

def input_gen_with_0x_pw_ifmap(golden_layer_decimal):
    '''Only for pw ifmap, because HW request pw ifmap need to begin from channel,then W, finally H.Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make it 4 element in a line, example of use : golden_gen(q_output_activation["Conv.3"]) '''
    golden_layer_decimal = golden_layer_decimal.permute(0,2,3,1)
    golden = []
    i=0
    golden_in_numpy = golden_layer_decimal.cpu().numpy()
    test = golden_in_numpy.flatten()
    test =test.astype('int32')
    golden.append([])
    for j, data in enumerate(test):
        if(j%4==0 ):
            golden.append([])
            i = i+1
            golden[i].append(signed_dec2hex(data))
        if(j%4!=0):
            golden[i].append(signed_dec2hex(data))
    golden.pop(0)
    temp = '0x'
    temp1 = ',\\'
    for indice,data in enumerate(golden):
        golden[indice].insert(0,temp)
        golden[indice].append(temp1)

    for indice,data in enumerate(golden):
        print(*data,sep='')
    return golden

def input_gen_with_0x_dw_ifmap(golden_layer_decimal):
    '''Only for pw ifmap, because pw ifmap need padding. Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make it 4 element in a line, example of use : golden_gen(q_output_activation["Conv.3"]) '''
    p2d = (1,1,1,1)
    golden_layer_decimal = torch.nn.functional.pad(golden_layer_decimal,p2d,"constant",0)
    golden = []
    i=0
    golden_in_numpy = golden_layer_decimal.cpu().numpy()
    test = golden_in_numpy.flatten()
    test =test.astype('int32')
    golden.append([])
    for j, data in enumerate(test):
        if(j%4==0 ):
            golden.append([])
            i = i+1
            golden[i].append(signed_dec2hex(data))
        if(j%4!=0):
            golden[i].append(signed_dec2hex(data))
    golden.pop(0)
    temp = '0x'
    temp1 = ',\\'
    for indice,data in enumerate(golden):
        golden[indice].insert(0,temp)
        golden[indice].append(temp1)

    for indice,data in enumerate(golden):
        print(*data,sep='')
    return golden

def customize_dw_input_gen(layer_decimal):
    '''Convert a layer output which is signed decimal in GPU to 8 bits hex with 2's complement in CPU and
     make each byte display in different place, example of use : input_or_weight_gen(quantized_model.Conv[1].weights)'''
    batch,channel,rows, cols = layer_decimal.shape
    patches = []
    for d in range(channel):
        for i in range(0, rows, 3):
            for j in range(0, cols, 3):
                patch = layer_decimal[0,d,i:i+3, j:j+3]
                patches.append(patch)
    temp_data_in_np = []
    for i , data in enumerate(patches):
        data =data.cpu()
        temp = np.array(data)
        temp_data_in_np.append(temp)
    temp_np = np.array(temp_data_in_np)
    temp_np = temp_np.flatten()

    byte0 = []
    byte1 = []
    byte2 = []
    byte3 = []

    # data_in_numpy = layer_decimal.cpu().numpy()
    # data_test = data_in_numpy.flatten()
    data_test =temp_np.astype('int32')
    data_test = signed_dec2hex_matrix(data_test)
    for indice,data in enumerate(data_test):
        if(indice%3 == 0):
            byte0.append(data)
            byte3.append('00')
        elif(indice%3 == 1):
            byte1.append(data)
        elif(indice%3 == 2):
            byte2.append(data)
        # else:
        #     byte3.append(data)
    print("byte0:",*byte0)
    print("=======")
    print("byte1:",*byte1)
    print("=======")
    print("byte2:",*byte2)
    print("=======")
    print("byte3:",*byte3)
    print("=======")
    return byte0,byte1,byte2,byte3

####### pw_ip_test #######

def pw_ip_test_weight_bias_file_gen(weight,bias):
    weight_byte0, weight_byte1, weight_byte2, weight_byte3 = input_or_weight_gen(weight)
    bias_byte0, bias_byte1, bias_byte2, bias_byte3 = bias_gen(bias)
    
    f = open('data_and_golden/pw_ip_test/weight0.hex', 'w')
    f.write("@00000000\n")
    f.write("00"+"\n")
    for i,data in enumerate(weight_byte0):
        f.write(data+"\n")
    ## bias
    f.write("00"+"\n")
    for i,data in enumerate(bias_byte0):
        f.write(data+"\n")
    f.write("@00100000\n")
    f.write("100")
    
    f.close()
    ##
    f = open('data_and_golden/pw_ip_test/weight1.hex', 'w')
    f.write("@00000000\n")
    f.write("00"+"\n")
    for i,data in enumerate(weight_byte1):
        f.write(data+"\n")
    ## bias
    f.write("00"+"\n")
    for i,data in enumerate(bias_byte1):
        f.write(data+"\n")
    f.write("@00100000\n")
    f.write("100")
    
    f.close()
    ##
    f = open('data_and_golden/pw_ip_test/weight2.hex', 'w')
    f.write("@00000000\n")
    f.write("00"+"\n")
    for i,data in enumerate(weight_byte2):
        f.write(data+"\n")
    ##bias
    f.write("00"+"\n")
    for i,data in enumerate(bias_byte2):
        f.write(data+"\n")
    f.write("@00100000\n")
    f.write("100")
    f.close()
    ##
    f = open('data_and_golden/pw_ip_test/weight3.hex', 'w')
    f.write("@00000000\n")
    f.write("F0"+"\n")
    for i,data in enumerate(weight_byte3):
        f.write(data+"\n")
    ##bias
    f.write("F0"+"\n")
    for i,data in enumerate(bias_byte3):
        f.write(data+"\n")
    f.write("@00100000\n")
    f.write("100")
    f.close()

def pw_ip_test_golden_file_gen(output):

    golden = golden_gen(output)
    f = open('data_and_golden/pw_ip_test/golden.hex', 'w')
    for i,data in enumerate(golden):
        print(*data,sep='',file=f)
    f.close()
########################