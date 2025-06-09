`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2025 15:00:55
// Design Name: 
// Module Name: all_module_ckt_tb
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


module all_module_ckt_tb;
    parameter ch_num=16;
    parameter op_data_width=16;
    parameter kernel_size=3;
    
    parameter op_buff_ROW=(16-kernel_size+1)*op_data_width;//same for col
    
    reg clk;
    initial begin
        clk=0;
    end
    
    always #5 clk=~clk;
    all_module_ckt uut(clk);
    initial begin
    //DONT WRITE MULTILINE STRING IN VERILOG
        $monitor("time: %0t |count: %d|rw_mem:%b| row_ker: %d | col_ker: %d | databus: %h |ip_buff_add:%d| ip_buff_mode: %b | ip_op_enable: %b | ip_buff_op: %h |core_load: %b | core_ready: %b|core_op: %h|op_ready:%b| op_row_add: %d | op_col_add:%d | op_buff: row0: %h| row1:%h", 
         $time, uut.cu.counter,uut.rw_mem,uut.row_ker, uut.col_ker, uut.data_bus,uut.ip_buff_add, uut.ip_buff_mode, 
         uut.ip_buff_op_enable,uut.ip_buff_data_out,uut.core_data_load,uut.core_ready,uut.core_op,
         uut.op_store.op_ready,uut.op_buff_row,
         uut.op_buff_col,uut.op_store.op_mem[0],uut.op_store.op_mem[1]);

        
        #40000 $finish;
    end
endmodule
