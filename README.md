# Image-convolution-Verilog
The verilog code to make a module for Image convolution (16x16x16) with 16 filters each of (3x3x16)

**Specs:** 
1. The weights and image pixels are 8 bit each and the result are 16bit.
2. The indexing in the image_array while storing, loading of input buffer array, output buffer all are done in such a way st. it feels same as working with arrays in languages like c,c++ (index 0 means leftmost element, which feels more natural). The user can give indices in this manner and the data is handled in that way.
3. When the whole output generation is complete "op_ready" signal =1, there will be no change in the output storage registers (col address went beyond the feature map dimension).
4. The common data-bus used is of 24 bits (3pixels), input buffer of 144 pixels (for 3x3 kernel and 16 channels).

## Overall Approach:
1. The kernel moves along the row, keeping the column (1st element(leftmost)) constant, from top to bottom. Then again starts at top in next, 1 col right and does the same.
2. Per clock cycle the data bus of 24 bits (3 pixels) reads pixels along the column of a particular row (r,0  r,1  r,2). When a channel is finished it goes to next channel by adding row size of the image to row_add.
3. When the kernel is at row 0 of a column, it loads all 9 pixels of each channel to input buffer. As the movement happens by stride 1 along the row, only the new pixels are loaded and old pixels are shifted.
4. After the buffer is completely loaded the pixels are sent to core, where it handles all the channels of the image in parallel manner (for a particular filter),producing the output by performing dot product of same channel pixels with all the corresponding indexed weights of the filter channel. Then in the same manner produce the other filters dot product.
5. Each time core produces the output they are loaded into output buffer where the final convoluted image is stored.

More detailed description of the approach is given in pdf.

## Here is the overall working of the modules:

1. The image memory (RISING CLK EDGE TRIGGERED) has the architecture of (16x16,16x8). The channels are stacked along the row and each (16,16x8) is 1 channel of the image. The bits for each pixel are stored along the columm in the same row. The data is loaded from the "image_7_ok.data"  file so the reading functionality of it is not used separately in the whole ckt. The reading is pretty simple, give the row and col index, and the 8bit input data (1pixel) will be loaded at that co-ordinate. For the data fetching, as the data-bus fetches pixels along the column,when input address row, col are given it gives the 3pixel along the columns of same row.
   
2. The input buffer (NEGATIVE CLK EDGE TRIGGERED) is made of 16 (channel no.) blocks, group of 3 rows,each of 3pixel storage (24 bit pipo). Here these blocks have 2 modes:
   * mode 0: load the 24bit data arrived at the row_address given (straightforward row filling).
   * mode 1: shift the row:2 (bottom-most) pixels to row:1. Same for row:1 pixels. Then load the 24 bit data in the bottom most row.
   After the buffer is filled completely (or mode-1 loading to all channels done), it's output enable is on and core accesses it's data.  

3. The Core: Almost totally combinatorial circuitry. The idea of core was to handle all the channels of the image in parallel manner (for a particular filter),producing the output by performing dot product of same channel pixels with all the corresponding indexed weights of the filter channel. Then in the same manner produce the other filters dot product with clock (serially). This was a totally valid and doable approach as the input buffer loads in 16 (channel num) clock cycles (when the kernel traverses), and 1 filter output in 1 Tclk,thus all filter outputs within 16Tclk. After completing for all channels it gives the "core_ready" signal as 1 for 1 Tclk,by def. set to 0. But due to time constraints, it's calculation is modelled behaviourally, all channel and filters output produced at once,but the way of for loop written tries to keep this approach.

4. The Control Unit: This module just taking the core_ready and clk signals as input, produces all necessary signals (keeping in mind the rising edge and falling edge distinction and so the Tclk/2 buffer time for core to load input buffer data before new data comes):
   * input image memory row and column address (kernel movement simulation)
   * input buffer mode, the row address, output enable
   * core's load data
   * output buffer's load data, the row and column address to store the core computed pixels each time

5. Output storage: A simple address based pixel storage module following the same leftmost=0 indexing. Stores the output in register (14x16,14x16), bits are along column, feature map size (14x14).
