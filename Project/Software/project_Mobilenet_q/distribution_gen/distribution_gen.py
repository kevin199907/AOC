from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap

def s16(value):
    return -(value & 0x80) | (value & 0x7f)

def read_data_preprocess(read_data):
    '''clean change line signal'''
    cleaned_list = [item.strip() for item in read_data]
    return cleaned_list



def signed_hex2dec(input_data):
    hex_data =[]
    for indice,data in enumerate(input_data):
        pairs = [data[i:i+2] for i in range(0, len(data),2)]
        for pairs_indice,pairs_data in enumerate(pairs):
            hex_data.append(pairs_data)
    true_hex = []
    for data in hex_data:
        true_hex.append(s16(int(data,16)))
    return true_hex


f = open("input.txt",mode='r')
data = f.readlines()
temp = []
cleaned_list = read_data_preprocess(data)
temp = signed_hex2dec(cleaned_list)
#print(temp)

f.close()

plt.hist(temp, bins='auto',density=False)
plt.show()
