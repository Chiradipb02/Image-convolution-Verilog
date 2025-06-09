`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2025 23:12:05
// Design Name: 
// Module Name: shuffle_buffer
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


module shuffle_buffer(//a set of 9 buffers [for 1 kernel (1ch)]
    clk,enable,data_in,row_add,mode,data_out,reset,op_enable
    );
    parameter kernel_size=3;
    parameter data_width=8;
    parameter pipo_width=kernel_size*data_width;
    
    input wire clk,mode,reset,op_enable;
    input wire [pipo_width-1:0]data_in;//the 24 bit databus
    input wire [1:0]row_add;//for any kernel size it is the nearest 2^pow<kernel size-1
    output reg [pipo_width*kernel_size-1:0]data_out;
    integer i;
    reg shuffle_done;
    reg [pipo_width-1:0] buffer [kernel_size-1:0];
    input wire enable;
    
    
    
    //mode=1 reorder then store
    always @(posedge clk) begin//the mode is updated at posedge of clk only
        if(enable==1 && mode==1)begin
        for(i=0;i<kernel_size-1;i=i+1)begin
            buffer[i]=buffer[i+1];//blocking should be done these transfer are 1 after another
        end
        shuffle_done=1;
        end
    end
    
    //the databus brings new 24bit data at each rising edge of the clock [acc to other modules]
    //at the same time the control system will make the mode=0/1. so to avoid clk rising edge vs mode conflict
    //the data is loaded at negative edge of clk
    always @(negedge clk) begin 
        if(enable==1)begin
            if (mode == 0) begin // normal loading
                buffer[row_add] <= data_in;
            end   
             
            else if (mode == 1 && shuffle_done == 1) begin 
                buffer[kernel_size-1] <= data_in;  // ? NON-BLOCKING ASSIGNMENT
                shuffle_done <= 0;                 // ? NON-BLOCKING ASSIGNMENT
            end 
       end
    end

    
    always @(*) begin//keep the output on, otherwise problem while loading to core
    //the core_load_data handles it [whenever the buffer completes, core loads the data]
        
            for(i=0;i<kernel_size;i=i+1)begin
                data_out[(pipo_width*kernel_size-1)-(i*pipo_width)-:pipo_width]<=buffer[i];
            end
        
    end
endmodule
