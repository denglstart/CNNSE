`include "paramter.v"

module requantizer (
    input  wire signed [`POOL_OUT_WIDTH-1:0] pool_val,
    output wire [3:0] lut_idx 
);
    // 采用饱和截断逻辑，将池化后的电压映射回 4-bit 索引
    // 假设 pool_val 为 12-bit，取中间有效位，并限制在 0-15 范围内
    wire [5:0] temp = pool_val[`POOL_OUT_WIDTH-1 : `POOL_OUT_WIDTH-6] + 6'd32;
    assign lut_idx = (temp[5]) ? 4'd15 : (temp[4:0] > 5'd15) ? 4'd15 : temp[3:0];
endmodule