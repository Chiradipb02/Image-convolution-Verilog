module core(
    ip_buffer_data_in, load_data, data_out,ready
);
    parameter kernel_size = 3;      
    parameter filter_num = 16;              
    parameter data_width = 8;                     
    parameter pipo_width = kernel_size * data_width;
    parameter output_width = 16;
    parameter channel_num = 16;
    
    parameter weight_mem_width = data_width * filter_num; //128
    parameter weight_mem_height = kernel_size * kernel_size * channel_num; //144
    
    input wire [weight_mem_height*data_width-1:0] ip_buffer_data_in; // (144*8,1)
    input wire load_data;
    output reg [filter_num*output_width-1:0] data_out;

    reg [weight_mem_width-1:0] weight_mem [0:weight_mem_height-1];
    reg [data_width-1:0] bias_mem [0:channel_num-1];
    
    initial begin
        $readmemh("weights.data", weight_mem);
        $readmemh("bias.data", bias_mem);
    end

    integer i, j;
    reg [23:0] result; // Safe accumulator size
    reg [filter_num*output_width-1:0] op_result;
    reg [weight_mem_height*data_width-1:0] data_store;//store the ip buffer data as soon as available
    output reg ready;
    
    initial begin//ensure this as it will be used by control system
        ready=0;
    end

    always @(posedge load_data) begin
        ready=0;
        data_store=ip_buffer_data_in;
        for (j = 0; j < filter_num; j = j + 1) begin//along col
            result = 0;
            for (i = 0; i < weight_mem_height; i = i + 1) begin//sum along row
                result = result + 
                    data_store[weight_mem_height*data_width - 1 - i*data_width -: data_width] *
                    weight_mem[i][weight_mem_width - 1 - j*data_width -: data_width];
            end
            result=result+bias_mem[j];
            op_result[filter_num*output_width - 1 - j*output_width -: output_width] = result[23 -:output_width];
        end
        data_out = op_result;
        ready=1;//turn off this ready signal after some delay [within ch_num*Tclk] / without the delay considerations, negedge of load_data
    end
    
    always @(negedge load_data)begin//the load_data is updated each clock cycle, so it is high at max Tclk
        ready=0;
    end
endmodule
