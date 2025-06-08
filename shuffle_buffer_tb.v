`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 23:58:14
// Design Name: 
// Module Name: shuffle_buffer_tb
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


module shuffle_buffer_tb;
    // Parameters
    parameter kernel_size = 3;
    parameter data_width = 8;
    parameter pipo_width = kernel_size * data_width;

    // Signals
    reg clk, mode, reset, op_enable;
    reg [pipo_width-1:0] data_in;
    reg [1:0] row_add;  // Supports values up to 3
    wire [pipo_width*kernel_size-1:0] data_out;

    // Instantiate the DUT
    shuffle_buffer #(kernel_size, data_width) uut (
        .clk(clk),
        .data_in(data_in),
        .row_add(row_add),
        .mode(mode),
        .data_out(data_out),
        .reset(reset),
        .op_enable(op_enable)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;


    // Test Sequence
    initial begin
        // Initialize
        mode = 0; reset = 0; op_enable = 0;
        data_in = 24'h000000; row_add = 0;

        $monitor("Time=%0t | clk=%b | mode=%b | row_add=%0d | data_in=%h | data_out=%h", 
                  $time, clk, mode, row_add, data_in, data_out);

        // Load data into buffer rows
        #5 data_in = 24'hAA0001; row_add = 0; // clk = 1
        #10 data_in = 24'hBB0002; row_add = 1;
        #10 data_in = 24'hCC0003; row_add = 2;

        // Trigger shuffle
        #10 mode = 1;data_in = 24'hFF0005; row_add = 1;
        #10 mode = 0;data_in = 24'hDD0004;row_add=1;  // mode pulse to simulate shuffle done

        // Output enable (read full buffer)
        #10 op_enable = 1;
        #10 op_enable = 0;

        // Finish
        #20 $finish;
    end
endmodule

