`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2025 23:45:49
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    clk,core_ready,row_ker,col_ker,ip_buff_add,ip_buff_op_enable,ip_buff_mode,rw_mem,core_data_load,op_buff_row,op_buff_col,op_buff_write
    );
    parameter row_image=16;
    parameter col_image=16;
    parameter image_row_add_bit=8;//16rows 16ch
    parameter image_col_add_bit=8;//16col
    parameter data_width=8;
    parameter buffer_add_bit=6;
    parameter kernel_size=3;
    parameter ch_num=16;
    parameter bus_width=3;//pixel number in bus
    
    //clk cycle to complete loading 1 column of the image mem array
    parameter n_cycle_col=(kernel_size*kernel_size*ch_num/bus_width)+(row_image-kernel_size)*(kernel_size*ch_num/bus_width);//256
    //clk cycles to load the initial 9 pixels of all channels 
    parameter n_init=kernel_size*kernel_size*ch_num/bus_width;//48
    
    
    input wire clk,core_ready;
    output reg ip_buff_mode,ip_buff_op_enable,core_data_load;
    output reg [image_row_add_bit-1:0] row_ker;
    output reg [image_col_add_bit-1:0] col_ker;
    output reg [buffer_add_bit-1:0] ip_buff_add;//the row address of 3pixel regs in each buffer grp
    output wire rw_mem;
    output reg op_buff_write;
    assign rw_mem=1;//always read from the memory
    
    integer counter;
    reg [7:0] clk_mod;//time taken to travel 1 column full
    integer op_count_ready;
    //initialize all the regs
    initial begin
        counter=0;
        ip_buff_op_enable=0;
        ip_buff_mode=0;
        core_data_load=0;
        op_count_ready=0;
        op_buff_write=0;
    end
    
    always @(posedge clk)begin
    //WHILE TB TESTING:ALL THE NEW EVALUATED VALUES ARE PRINTED IN EACH RISING EDGE. SO ALL REGS ARE EVALUATED USING THE OLD COUNTER VALUE AND THE PRINTED COUNTER:OLD
    //default
        ip_buff_mode=0;
        ip_buff_op_enable=0;
        
        clk_mod=counter%n_cycle_col;
        
        //input image memory address[beginning pixel index]
        col_ker=(counter/n_cycle_col)*data_width*kernel_size;//1 col finished, then load 24 bits right
        //beware of the logic!!!
        row_ker=(clk_mod>=n_init)?(kernel_size+(clk_mod-n_init)/ch_num+((clk_mod-n_init)%ch_num)*ch_num):(clk_mod/kernel_size)*ch_num+clk_mod%kernel_size;
        
        //ONLY 1 CONDITIONAL TO EXECUTE OTHERWISE OVERWRITE
        //ONLY POTENTIAL ISSUE: AFTER THE PASSING OF LIMITING COUNTER DATA, IN THE NEXT CYCLE THE LOAD=1
        //THE IP_BUFFER IS NEGATIVE EDGE TRIGGERED THOUGH, SO THE NEW DATA SENT IN THAT CYCLE AT +VE EDGE, WILL BE LOADED IN BUFFER T/2 LATER
        //SO CORE HAS T/2 TIME BUFFER
        
        //1 col finished so load
        if(clk_mod==0 && counter/n_cycle_col>=1) begin
            ip_buff_op_enable=1;
            core_data_load=1;
        end
        
        //1st position done, load the data & keep it stable for 1 clk cycle
        else if(clk_mod==n_init)begin 
            ip_buff_op_enable=1; core_data_load=1;//1st this
            ip_buff_mode=1;//then this [to avoid 1 cycle miss]
            ip_buff_add=0;
            end
            
        //1st pos in progress, the ip_buffer just requires the row of pipo
        //number of rows=48, so the clk_mod itself is enough
        else if(clk_mod<n_init)begin
            ip_buff_mode=0;
            ip_buff_op_enable=0;
            core_data_load=0;
            ip_buff_add=clk_mod;
        end
        
        //after 1st position every channel requires just 1 clk cycle and reorder the already loaded pixel
        else if(clk_mod>n_init) begin
            ip_buff_mode=1;
            ip_buff_add=(ip_buff_add+kernel_size)%n_init;//JUST LOAD THE 1ST ROW INDEX OF THE BUFFER GRP, MODE =1 WILL MANAGE
            if(clk_mod%ch_num==0)begin 
                ip_buff_op_enable=1; core_data_load=1;
            end
            else begin
                ip_buff_op_enable=0; core_data_load=0;
            end
        end
        
        
        counter=counter+1;
    end
    
    parameter op_data_width=16;
    parameter op_buff_ROW=(16-kernel_size+1)*op_data_width;//same for col
    //val:14x16=224
    output reg [7:0] op_buff_row;
    output reg [7:0] op_buff_col;
    //computation complete for a partucular kernel position, then ready=1.
    //at the neg edge of load_data it is set to 0 again [assuming 1 clk cycle is enough to calculate]
    always @(posedge core_ready)begin
        //the common part of the address for all filters
        op_buff_row=(op_count_ready%op_buff_ROW);
        op_buff_col=(op_count_ready/op_buff_ROW)*op_data_width;
        op_buff_write=1;
        op_count_ready=op_count_ready+1;
    end
    
    always @(negedge core_ready) op_buff_write=0;
endmodule
