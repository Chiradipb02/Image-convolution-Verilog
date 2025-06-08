`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 20:30:36
// Design Name: 
// Module Name: image_memory
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

//this is the image array of size (16x16ch,8x16)
module image_memory(
    row_add,col_add,r_w,data_in,data_out,reset,clk
    );
    parameter data_width=8;
    parameter row_mem_size=256;//row*channel
    parameter col_mem_size=128;//bit*col
    parameter row_add_width=8;
    parameter col_add_width=7;
    
    input wire [row_add_width-1:0] row_add;
    input wire [col_add_width-1:0] col_add;
    input wire [data_width-1:0] data_in;//a single 8 bit data vector
    input wire r_w,reset,clk;
    output reg [data_width*3-1:0] data_out;//continuous 3 pixels read
    integer i;
    reg [col_mem_size-1:0] mem [row_mem_size-1:0];
    initial begin
        $readmemh("image_7_ok.data",mem);
    end
    // Read only (combinational)
    always @(*) begin
        if (r_w == 0) begin
            data_out = mem[row_add][(col_mem_size-1-col_add)-:3*data_width];
        end
    end

    // Reset + Write
    always @(posedge clk) begin
        if (reset == 1) begin
            for (i = 0; i < row_mem_size; i = i + 1)
                mem[i] <= 0;
        end
        else if (r_w == 1) begin
            mem[row_add][(col_mem_size-1-col_add)-:data_width] <= data_in;
        end
    end
    
endmodule
