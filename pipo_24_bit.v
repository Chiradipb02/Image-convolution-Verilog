`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 23:05:34
// Design Name: 
// Module Name: pipo_24_bit
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


module pipo_24_bit(
    clk,data_in,data_out,reset
    );
    parameter kernel_size=3;
    parameter data_width=8;
    parameter pipo_width=kernel_size*data_width;
    input wire clk,reset;
    input wire [pipo_width-1:0] data_in;
    output reg [pipo_width-1:0] data_out;
    
    always @(posedge clk or posedge reset)begin
        if(reset==0) data_out<=0;
        else data_out<=data_in;
    end
endmodule
