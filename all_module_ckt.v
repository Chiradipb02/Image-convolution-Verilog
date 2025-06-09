`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2025 22:08:57
// Design Name: 
// Module Name: all_module_ckt
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module all_module_ckt(
    clk
    );
    //for now the input image is already loaded in the input memory module from a hex file
    //same goes with the weights, they are loaded in the weights_mem of core
    //the op 16bit data will be accessible in the op_storage module's op_mem reg
    
    parameter row_image=16;
    parameter col_image=16;
    parameter image_row_add_bit=8;//16rows 16ch
    parameter image_col_add_bit=8;//16col
    parameter data_width=8;
    parameter buffer_add_bit=6;
    parameter kernel_size=3;
    parameter ch_num=16;
    parameter bus_width=3;//pixel number in bus
    parameter op_data_width=16;
    parameter op_buff_ROW=(16-kernel_size+1)*op_data_width;//same for col
    //clk cycle to complete loading 1 column of the image mem array
    parameter n_cycle_col=(kernel_size*kernel_size*ch_num/bus_width)+(row_image-kernel_size)*(kernel_size*ch_num/bus_width);//256
    //clk cycles to load the initial 9 pixels of all channels 
    parameter n_init=kernel_size*kernel_size*ch_num/bus_width;//48
    
    input wire clk;
    
    //input(core_ready) and op of control unit
    wire core_ready,ip_buff_op_enable,ip_buff_mode,rw_mem,core_data_load,op_buff_write;
    wire [image_row_add_bit-1:0] row_ker;
    wire [image_col_add_bit-1:0] col_ker;
    wire [buffer_add_bit-1:0] ip_buff_add;
    wire [7:0] op_buff_row;
    wire [7:0] op_buff_col;
    
    //the common 24  bit data bus
    wire [data_width*kernel_size-1:0] data_bus;
    //the wire to send data from ip buffer to core
    wire [kernel_size*kernel_size*ch_num*data_width-1:0] ip_buff_data_out;//144*8 bit
    //core to op_buffer wire
    wire [op_data_width*ch_num-1:0] core_op;
    
    //the brain of all the components
    control_unit cu(.clk(clk),.core_ready(core_ready),.row_ker(row_ker),.col_ker(col_ker),
    .ip_buff_add(ip_buff_add),.ip_buff_op_enable(ip_buff_op_enable),.ip_buff_mode(ip_buff_mode),.rw_mem(rw_mem),.core_data_load(core_data_load),
    .op_buff_row(op_buff_row),.op_buff_col(op_buff_col));
    
    //the image memory [x]
    image_memory img_mem(.row_add(row_ker),.col_add(col_ker),.r_w(0),.data_out(data_bus),.clk(clk));//not using data_in and reset pins
    
    //ip_buffer stage
    input_buffer ip_buff(.input_add(ip_buff_add), .mode(ip_buff_mode), .clk(clk),
     .op_enable(ip_buff_op_enable), .data_in(data_bus), .data_out(ip_buff_data_out));
     
     //the Convolution operation core:
     core cc(.ip_buffer_data_in(ip_buff_data_out), .load_data(core_data_load), .data_out(core_op),.ready(core_ready));
    
     //op_buffer and storage
     output_storage op_store(.ready_signal(core_ready),.core_out(core_op),.ip_row(op_buff_row),.ip_col(op_buff_col));
endmodule
