`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.06.2025 15:16:38
// Design Name: 
// Module Name: output_storage
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

module output_storage(
    ready_signal,core_out,ip_row,ip_col
    );
    parameter ch_num=16;
    parameter op_data_width=16;
    parameter kernel_size=3;
    parameter op_ft_map_row=16-3+1;
    parameter op_buff_ROW=(16-kernel_size+1)*op_data_width;//same for col
    //row_size=col_size=14x16
    input wire ready_signal;
    input wire [ch_num*op_data_width-1:0] core_out;
    input wire [7:0] ip_row;
    input wire [7:0] ip_col;
    
    
    reg [op_buff_ROW-1:0] op_mem [op_buff_ROW-1:0];//bits along the col in single row
    reg op_ready;
    initial begin 
        op_ready=0;
    end
    integer ch_ind;
    
    //only problem: for 1st position in row, it is not loading the pixel value [reason unknown till now]
    always @(posedge ready_signal) begin
        if (ip_row < op_buff_ROW && ip_col < op_buff_ROW) begin
            for(ch_ind=0;ch_ind<ch_num;ch_ind=ch_ind+1)begin
                op_ready <= 1;//done for debugging purpose
                op_mem[ip_row+op_ft_map_row*ch_ind][op_buff_ROW-1-ip_col*op_data_width -:op_data_width]<=core_out[ch_num*op_data_width-1-ch_ind*op_data_width -:op_data_width];
                end
            
        end
    end
    
    always @(*) begin 
        //op_ready=0;
        if(ip_col>=op_buff_ROW) op_ready=2;
    end
endmodule
