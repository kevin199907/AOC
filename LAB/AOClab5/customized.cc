#include <assert.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

#include <algorithm>
#include <fstream>
#include <iostream>
#include <iterator>
#include <numeric>
#include <string>
#include <vector>

#include "AoC.cc"
#include "customized_kernel.h"

#define DRAM_BASE 0
#define DRAM_WEIGHT_OFFSET 0
#define DRAM_INPUT_OFFSET 268435456
#define DRAM_OUTPUT_OFFSET (268435456 + 268435456)

#define DRAM_WEIGHT_START_ADDR (DRAM_BASE+DRAM_WEIGHT_OFFSET)
#define DRAM_INPUT_START_ADDR (DRAM_BASE+DRAM_INPUT_OFFSET)
#define DRAM_OUTPUT_START_ADDR (DRAM_BASE+DRAM_OUTPUT_OFFSET)

#define DRAM_2_SRAM 0
#define SRAM_2_DRAM 1
#define tiled_size 28


namespace tvm {
namespace runtime {
namespace contrib {
extern "C" void customized_conv2d(int8_t *data, int8_t *weights, int *out,
                                  int ifmap_N, int ifmap_C, int ifmap_H, int ifmap_W,
                                  int filter_N, int group, int padding_T, int padding_L,
                                  int padding_B, int padding_R, int filter_H, int filter_W,
                                  int stride_H, int stride_W) {
    std::vector<uint64_t> buf;

    int tiled_stride_h = tiled_size-filter_H+1;
    int tiled_stride_w = tiled_size-filter_W+1;
    int padded_w = ifmap_W + padding_L + padding_R;
    int padded_h = ifmap_H + padding_T + padding_B;

    encode_layer_config(buf, ifmap_W, ifmap_H, ifmap_C - 1);

/////////////////////////////////////////////////////////////////
////////////////////////modify code below////////////////////////
/////////////////////////////////////////////////////////////////

    /* According to the DRAM, calculate 8 channels of output once */
    for (int out_c = 0; out_c < filter_N; out_c += 8) {
        uint64_t loaded_filter_num = filter_N - out_c > 8 ? 8 : filter_N - out_c;
			
		
        // height loop
        for (int j = 0; j < ifmap_H + 1; j += tiled_stride_h) {

            // weight loop
            for (int i = 0; i < ifmap_W + 1; i += tiled_stride_w) {
                uint64_t dram_addr;

                int tiled_w = std::min(tiled_size, ifmap_W - i + 2);  // width you tiled to transfer ifmap from DRAM to SRAM
                int tiled_h = std::min(tiled_size, ifmap_H - j + 2); // height you tiled to transfer ifmap from DRAM to SRAM
                int padding_t = (j == 0) ? 1 : 0; // top padding or not(1 for padding)
                int padding_l = (i == 0) ? 1 : 0; // left padding or not(1 for padding)
                int padding_r = (i + tiled_w >= ifmap_W + 2) ? 1 : 0; // right padding or not(1 for padding)
                int padding_b = (j + tiled_h >= ifmap_H + 2) ? 1 : 0; // bottom padding or not(1 for padding)


                for (int k = 0; k < ifmap_C; k += 8) {
                    int loaded_channels = ifmap_C - k > 8 ? 8 : ifmap_C - k;

                    // loading weight from DRAM to SRAM
                    dram_addr = DRAM_BASE + DRAM_WEIGHT_OFFSET +
                                filter_W * filter_H * ifmap_C * out_c +
                                filter_W * filter_H * k;
                    encode_tranfer_config(buf, filter_W, filter_H,
                                          loaded_channels - 1,
                                          loaded_filter_num - 1 | filter_W << 6 | filter_H << 3,
                                          0, 0, 0, 0, DRAM_2_SRAM, 0, 0);
                    encode_tranfer_addr(buf, dram_addr);

                    // loading ifmap from DRAM to SRAM
                    //ifmap dram_addr you define!!!
					if ((j == 0) && (i == 0)){
						dram_addr = DRAM_INPUT_START_ADDR + ifmap_W * ifmap_H * k;
					} else if (j == 0) {
						dram_addr = DRAM_INPUT_START_ADDR + ifmap_W * ifmap_H * k + (i - 1);
					} else if (i == 0) {
						dram_addr = DRAM_INPUT_START_ADDR + ifmap_W * ifmap_H * k + (j - 1) * ifmap_W;
					} else {
						dram_addr = DRAM_INPUT_START_ADDR + ifmap_W * ifmap_H * k + (j - 1) * ifmap_W + (i - 1);
					}
                    //dram_addr = DRAM_INPUT_START_ADDR + ;
                    encode_tranfer_config(
                        buf, tiled_w - padding_l - padding_r,
                        tiled_h - padding_t - padding_b, loaded_channels - 1,
                        ifmap_W, padding_r,
                        padding_l, padding_b, padding_t, DRAM_2_SRAM, 1, 1);
                    encode_tranfer_addr(buf, dram_addr);

                    // PE array compute 
                    int reset_ofmap = (k==0) ? 1 : 0;
                    encode_computation(buf, tiled_w, tiled_h,
                                       loaded_channels - 1, stride_W - 1, filter_W,
                                       filter_H, loaded_filter_num - 1, reset_ofmap);
                }
              
                // saving ofmap from SRAM to DRAM
                //ofmap dram_addr you define!!!
				dram_addr = DRAM_OUTPUT_START_ADDR + ifmap_W * ifmap_H * out_c + j * ifmap_W + i;

				
                //dram_addr = DRAM_OUTPUT_START_ADDR + ;
                encode_tranfer_config(
                    buf, tiled_w - filter_W + 1, tiled_h - filter_H + 1,
                    loaded_filter_num - 1, padded_w - filter_W + 1, 0, 0, 0, 0,
                    SRAM_2_DRAM, 0, 2);
                encode_tranfer_addr(buf, dram_addr);
            }
        }
    }
/////////////////////////////////////////////////////////////////
////////////////////////modify code above////////////////////////
/////////////////////////////////////////////////////////////////


    std::vector<int> w;
    for (int i = 0; i < filter_W * filter_H * ifmap_C * filter_N; i++) {
        w.push_back((int)*(weights + i));
    }
    std::vector<int> in;
    for (int i = 0; i < ifmap_W * ifmap_H * ifmap_C * ifmap_N; i++) {
        in.push_back((int)*(data + i));
    }

    buf.push_back(0b1111111111111101);
    std::ofstream output_file("./inst.txt");
    std::ostream_iterator<std::uint64_t> output_iterator(output_file, "\n");
    std::copy(std::begin(buf), std::end(buf), output_iterator);
    output_file.close();
    std::ofstream output_file_("./weights.txt");
    std::ostream_iterator<int> output_iterator_(output_file_, "\n");
    std::copy(std::begin(w), std::end(w), output_iterator_);
    output_file_.close();
    std::ofstream output_file__("./input.txt");
    std::ostream_iterator<int> output_iterator__(output_file__, "\n");
    std::copy(std::begin(in), std::end(in), output_iterator__);
    output_file__.close();

    system("./accelerator");

    std::ifstream result_file("./result.txt");
    for (int i = 0; i < (padded_w - filter_W + 1) * (padded_h - filter_H + 1) * filter_N; i++)
        result_file >> out[i];
    result_file.close();
}
} // namespace contrib
} // namespace runtime
} // namespace tvm