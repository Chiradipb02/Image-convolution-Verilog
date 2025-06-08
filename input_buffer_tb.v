`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2025 15:25:25
// Design Name: 
// Module Name: input_buffer_tb
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


module input_buffer_tb;

    parameter kernel_size = 3;
    parameter channel_num = 16;
    parameter data_width = 8;
    parameter pipo_width = kernel_size * data_width;
    parameter ip_buffer_size = kernel_size * kernel_size * channel_num * data_width;
    parameter shuffle_buffer_width = kernel_size * pipo_width;
    parameter buff_addbit = 6;

    reg clk, mode, op_enable, reset;
    reg [buff_addbit-1:0] input_add;
    reg [pipo_width-1:0] data_in;
    wire [ip_buffer_size-1:0] data_out;

    input_buffer uut (
        .input_add(input_add),
        .mode(mode),
        .clk(clk),
        .op_enable(op_enable),
        .data_in(data_in),
        .data_out(data_out),
        .reset(reset)
    );

    always #5 clk = ~clk;  // 10 time units period

    initial begin
        // Initial values
        clk = 0;
        reset = 0;
        mode = 0;
        op_enable = 0;
        input_add = 0;
        data_in = 24'h000000;

        $monitor("Time: %0t |mode:%b | output_enable: %b | input_add: %0d | data_in: %h | data_out[0+:144]: %h",
                  $time,mode,op_enable, input_add, data_in, data_out[ip_buffer_size-1 -:144]);

        // Write to buffer group 0, row 0
        #5 data_in = 24'hAABBCC;
            input_add = 6'd0; // grp_sel = 0, row_sel = 0
            mode = 0;  // normal write

        // Write to buffer group 1, row 1
        #10 data_in = 24'h112233;
            input_add = 6'd1; // grp_sel = 1, row_sel = 1

        // Enable output from all buffers
        #10 op_enable = 1;

        // Wait for output to stabilize
        #10 op_enable = 0;
        
        // Write to buffer group 1, row 1
        #10 data_in = 24'h223344;
            input_add = 6'd2; // grp_sel = 1, row_sel = 1
        
        #10 data_in = 24'h334455;
            input_add = 6'd3; // grp_sel = 1, row_sel = 1
            
        #10 data_in = 24'h445566;
            input_add = 6'd4; // grp_sel = 1, row_sel = 1
        #10 data_in = 24'h667788;
            input_add = 6'd5; // grp_sel = 1, row_sel = 1
        
        #10 mode=1;data_in=24'hBBCCDD;input_add=6'd4;

        // Reset everything
        #10 op_enable=1;
        

        #20 $finish;
    end

endmodule

