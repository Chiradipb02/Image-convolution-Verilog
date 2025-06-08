`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2025 16:19:53
// Design Name: 
// Module Name: output_storage_tb
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



module output_storage_tb;

    parameter ch_num = 16;
    parameter op_data_width = 16;
    parameter kernel_size = 3;
    parameter op_buff_ROW = (16 - kernel_size + 1) * op_data_width;

    reg ready_signal, r_w;
    reg [ch_num * op_data_width - 1:0] core_out;
    reg [7:0] ip_row, ip_col;
    
    // DUT
    output_storage  uut (
        .ready_signal(ready_signal),
        .core_out(core_out),
        .ip_row(ip_row),
        .ip_col(ip_col),
        .r_w(r_w)
    );

    initial begin
        $monitor("time: %0t | ready: %b | r_w: %b | core_out: %h | ip_row: %d | ip_col: %d",$time,ready_signal,r_w,core_out,ip_row,ip_col);
        // Initialize inputs
        ready_signal = 0;
        r_w = 0;
        core_out = 0;
        ip_row = 0;
        ip_col = 0;
        $display("op buffer 1st row: %h",uut.op_mem[0]);
        // Wait and write once
        #10;
        core_out = 64'hAABBCCDDAABBCCDD; // Example 4x8-bit data: AA, BB, CC, DD
        ip_row = 0;
        ip_col = 1;
        ready_signal = 1;
        r_w = 1;  // rising edge triggers write
        $display("op buffer 1st row: %h",uut.op_mem[0]);
        #10 r_w = 0;

        // Try writing again with different data and address
        #10;
        core_out = 64'h11223344AABBCCDD;
        ip_row = 1;
        ip_col = 2;
        r_w = 1;
        $display("op buffer 1st row: %h",uut.op_mem[0]);
        #10 r_w = 0;

        // Attempt write when ready_signal is 0 ? no write should occur
        #10;
        core_out = 64'h5566778811223344;
        ip_row = 2;
        ip_col = 3;
        ready_signal = 0;
        r_w = 1;
        #10 r_w = 0;
        $display("op buffer 1st row: %h",uut.op_mem[0]);
        $finish;
    end

endmodule

