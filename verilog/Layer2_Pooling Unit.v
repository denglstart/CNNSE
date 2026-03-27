`include "paramter.v"

module layer2_pooling #(
    parameter POOL_SIZE = 4  //设置为 4 或 8
)(
    input  wire clk,
    // 使用向量输入方便处理不同宽度
    input  wire signed [`LUT1_OUT_WIDTH*8-1:0] in_bus, 
    output reg signed [`POOL_OUT_WIDTH-1:0] pool_out
);
    // 内部加法树逻辑
    reg signed [`POOL_OUT_WIDTH-1:0] sum_l1 [3:0];
    reg signed [`POOL_OUT_WIDTH-1:0] sum_l2 [1:0];

    always @(posedge clk) begin
        if (POOL_SIZE == 4) begin
            // 4输入加法树
            sum_l1[0] <= in_bus[`LUT1_OUT_WIDTH*1-1 : `LUT1_OUT_WIDTH*0] + in_bus[`LUT1_OUT_WIDTH*2-1 : `LUT1_OUT_WIDTH*1];
            sum_l1[1] <= in_bus[`LUT1_OUT_WIDTH*3-1 : `LUT1_OUT_WIDTH*2] + in_bus[`LUT1_OUT_WIDTH*4-1 : `LUT1_OUT_WIDTH*3];
            pool_out  <= sum_l1[0] + sum_l1[1];
        end else if (POOL_SIZE == 8) begin
            // 8输入加法树
            sum_l1[0] <= in_bus[`LUT1_OUT_WIDTH*1-1 : 0] + in_bus[`LUT1_OUT_WIDTH*2-1 : `LUT1_OUT_WIDTH*1];
            sum_l1[1] <= in_bus[`LUT1_OUT_WIDTH*3-1 : `LUT1_OUT_WIDTH*2] + in_bus[`LUT1_OUT_WIDTH*4-1 : `LUT1_OUT_WIDTH*3];
            sum_l1[2] <= in_bus[`LUT1_OUT_WIDTH*5-1 : `LUT1_OUT_WIDTH*4] + in_bus[`LUT1_OUT_WIDTH*6-1 : `LUT1_OUT_WIDTH*5];
            sum_l1[3] <= in_bus[`LUT1_OUT_WIDTH*7-1 : `LUT1_OUT_WIDTH*6] + in_bus[`LUT1_OUT_WIDTH*8-1 : `LUT1_OUT_WIDTH*7];
            
            sum_l2[0] <= sum_l1[0] + sum_l1[1];
            sum_l2[1] <= sum_l1[2] + sum_l1[3];
            pool_out  <= sum_l2[0] + sum_l2[1];
        end
    end
endmodule