`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2025 11:00:53
// Design Name: 
// Module Name: input_buffer
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


module input_buffer(
    input_add, mode, clk, op_enable, data_in, data_out, reset
);
    parameter kernel_size = 3;
    parameter channel_num = 16;
    parameter data_width = 8;
    parameter pipo_width = kernel_size * data_width;//24bit bus
    parameter ip_buffer_size = kernel_size * kernel_size * channel_num * data_width;//144*8
    parameter shuffle_buffer_width = kernel_size * pipo_width;//72bit
    parameter buff_addbit = 6;//select between 48 rows of pipo

    input wire clk, mode, op_enable, reset;
    input wire [buff_addbit-1:0] input_add;
    input wire [pipo_width-1:0] data_in;
    output wire [ip_buffer_size-1:0] data_out;

    wire [3:0] grp_sel = input_add /kernel_size;  // log2(3)=2 => safe to shift by 2
    wire [1:0] row_sel = input_add % kernel_size;

    wire [channel_num-1:0] clk_select;
    genvar i;

    generate
        for (i = 0; i < channel_num; i = i + 1) begin : make_the_buffer
        //VV RISKY APPROACH: TO USE THIS KIND OF CLOCK GATING(CAN USE ENABLE INSTEAD), 1 WRONG SELECTION/RACING AND U ARE DONE
        //BUG: WHEN GRP NUM CHANGES, THE ADJACENT GROUPS GO THROUGH SAME OPERATION TOGETHER
        //IF THE GRP NUMBER DOES NOT MATCH, PROVIDE HIGH Z TO AVOID ANY KIND OF CLK LEVEL CHANGING
        //USING DEFAULT 0 RESULTS IN AN EXTRA NEGATIVE EDGE AND AS THE GRP_SEL AT JUST BEFORE
        //MOMENT IS 0 THE MODULO OPERATOR ACTS FAST AND GIVES 0, THUS RESULTING IN LOADING THE
        //ROW:2 DATA TO THE ROW 0 REGISTER OF THE SAME GROUP AGAIN
        
            wire enable=(i==grp_sel) ? 1:0;//<-- final fix
            //wire this_clk = (i == grp_sel) ? clk : 1'b0;
            //wire mode_this=(i==grp_sel) ? mode :'bz;
            shuffle_buffer buff (
                .clk(clk),.enable(enable),
                .data_in(data_in),
                .row_add(row_sel),
                .mode(mode),
                .data_out(data_out[ip_buffer_size-1 - i*shuffle_buffer_width -: shuffle_buffer_width]),
                .reset(reset),
                .op_enable(op_enable)
            );
            
            //assign ip_buff_op[ (i+1)*shuffle_buffer_width-1 : i*shuffle_buffer_width ] = shuffle_buffers[i].data_out;
        end
    endgenerate

endmodule

