`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2025 17:23:21
// Design Name: 
// Module Name: core_tb
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


module core_tb;
    parameter kernel_size = 3;      
    parameter filter_num = 16;              
    parameter data_width = 8;                     
    parameter pipo_width = kernel_size * data_width;
    parameter output_width = 16;
    parameter channel_num = 16;
    
    parameter weight_mem_width = data_width * filter_num; //128
    parameter weight_mem_height = kernel_size * kernel_size * channel_num; //144
    
    reg [weight_mem_height*data_width-1:0] ip_buffer_data_in; // (144*8 = 1152 bits)
    reg load_data;
    wire [filter_num*output_width-1:0] data_out; // 256 bits
    
    // DUT
    core uut (
        .ip_buffer_data_in(ip_buffer_data_in),
        .load_data(load_data),
        .data_out(data_out)
    );
    
    integer i;
    
    initial begin
        // Step 1: Initialize inputs
        load_data = 0;
        ip_buffer_data_in = {weight_mem_height{8'h01}}; // All input values = 1
        $display("data in buffer: %h",ip_buffer_data_in);
        // Step 2: Wait and apply stimulus
        #10 load_data = 1;  // Trigger computation
        #10 load_data = 0;
        $display("weight memory 1st row: %h",uut.weight_mem[0]);
        $display("weight memory 2nd row: %h",uut.weight_mem[1]);
        // Step 3: Wait and observe output
        #20;
        
        // Display output
        $display("Data Out:");
        for (i = 0; i < filter_num; i = i + 1) begin
            $display("Filter %0d Output: %h", i, data_out[filter_num*output_width-1 - i*output_width -: output_width]);
        end
        
        $finish;
    end
endmodule


