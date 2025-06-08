`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 21:13:22
// Design Name: 
// Module Name: memory_tb
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


module memory_tb;
    parameter data_width=8;
    parameter row_mem_size=256;//row*channel
    parameter col_mem_size=128;//bit*col
    parameter row_add_width=8;
    parameter col_add_width=7;
    
    reg [row_add_width-1:0] row_add;
    reg [col_add_width-1:0] col_add;
    reg [data_width-1:0] data_in;//a single 8 bit data vector
    reg r_w,reset,clk;
    wire [data_width*3-1:0] data_out;//continuous 3 pixels read
    
    always #5 clk=~clk;
    
    image_memory uut(row_add,col_add,r_w,data_in,data_out,reset,clk);
    initial begin
        clk=0;
        $monitor("time: %0t | r_w: %b | row_add: %d | col_add: %d | data_in:%h | data_out:%h",$time,r_w,row_add,col_add,data_in,data_out);
        $display("before editing line 0: %h",uut.mem[0]);
        $display("before editing line 1: %h",uut.mem[1]);
        r_w=0;reset=0;row_add=0;col_add=0;data_in=8'bx;
        #5 r_w=0;row_add=1;col_add=0;data_in=8'bx;
        #10 r_w=1;row_add=0;col_add=0;data_in=100;
        $display("after editing line 0: %h",uut.mem[0]);
        #10 r_w=0;row_add=0;col_add=0;data_in=8'bx;
        #10 reset=1;r_w=0;row_add=0;col_add=0;data_in=8'bx;
        #10 $finish;
    end
endmodule
