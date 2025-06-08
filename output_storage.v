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
    ready_signal,core_out,ip_row,ip_col,r_w
    );
    parameter ch_num=16;
    parameter op_data_width=16;
    parameter kernel_size=3;
    
    parameter op_buff_ROW=(16-kernel_size+1)*op_data_width;//same for col
    //row_size=col_size=14x16
    input wire ready_signal,r_w;
    input wire [ch_num*op_data_width-1:0] core_out;
    input wire [7:0] ip_row,ip_col;
    
    
    reg [op_buff_ROW-1:0] op_mem [0:op_buff_ROW-1];//bits along the col in single row
    reg op_ready;
    initial begin 
        op_ready=0;
    end
    integer ch_ind;
    
    always @(posedge r_w)begin
        //if goes out of bounds, does not get the clocking
        if(ready_signal && ip_col<op_buff_ROW)begin
           //top->0th channel image
           //core_out-> left most->0th channel
            for(ch_ind=0;ch_ind<ch_num;ch_ind=ch_ind+1)begin
                op_mem[ip_row+ch_num*ch_ind][op_buff_ROW-1-ip_col*op_data_width -:op_data_width]<=core_out[ch_num*op_data_width-1-ch_ind*op_data_width -:op_data_width];
            end
        end
    end
    
    always @(*) begin 
        op_ready=0;
        if(ip_col>=op_buff_ROW) op_ready=1;
    end
endmodule
