`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2025 11:06:37
// Design Name: 
// Module Name: control_unit_tb
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


module control_unit_tb;
    parameter row_image=16;
    parameter col_image=16;
    parameter image_row_add_bit=8;//16rows 16ch
    parameter image_col_add_bit=4;//16col
    parameter data_width=8;
    parameter buffer_add_bit=6;
    parameter kernel_size=3;
    parameter ch_num=16;
    parameter bus_width=3;//pixel number in bus
    
    //clk cycle to complete loading 1 column of the image mem array
    parameter n_cycle_col=(kernel_size*kernel_size*ch_num/bus_width)+(row_image-kernel_size)*(kernel_size*ch_num/bus_width);
    //clk cycles to load the initial 9 pixels of all channels 
    parameter n_init=kernel_size*kernel_size*ch_num/bus_width;
    
    reg clk,core_ready;
    wire [7:0] row_ker,op_buff_row,op_buff_col;
    wire [6:0] col_ker;
    wire [buffer_add_bit-1:0] ip_buff_add;
    wire ip_buff_op_enable,ip_buff_mode,core_data_load,rw_mem,op_buff_write;
    
    control_unit uut(.clk(clk),.core_ready(core_ready),.row_ker(row_ker),.col_ker(col_ker),
        .ip_buff_add(ip_buff_add),.ip_buff_op_enable(ip_buff_op_enable),
            .ip_buff_mode(ip_buff_mode),.rw_mem(rw_mem),.core_data_load(core_data_load),.op_buff_row(op_buff_row),.op_buff_col(op_buff_col),.op_buff_write(op_buff_write));
    
    always #5 clk=~clk;
    
    initial begin 
        clk=0;
        $monitor("time: %0t |counter:%d| img_row:%d | img_col: %d | ip_buff_mode: %b | ip_buff_row: %d | ip_op_enable: %b | core_load: %b | core_ready: %b| op_buff_write: %b | op_buff_row: %d | op_buff_col:%d",
            $time,uut.counter,row_ker,col_ker,ip_buff_mode,ip_buff_add,ip_buff_op_enable,core_data_load,core_ready,op_buff_write,op_buff_row,op_buff_col);
        #490 core_ready=1;
        #10 core_ready=0;
        #160 core_ready=1;
        #10 core_ready=0;
        #3000 ;
        #10 $finish;
    end
endmodule
