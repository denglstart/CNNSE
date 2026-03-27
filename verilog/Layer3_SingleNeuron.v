`include "paramter.v"

module layer3_neuron_pe #(
    parameter NEURON_ID = 0,
    parameter signed [15:0] BIAS_VALUE = 16'sd0
)(
    input  wire clk,
    // 输入维度为 210 个特征点，每个点经过量化后为 4bit 索引，总计 840 bit
    input  wire [210*4-1:0] flat_indices, 
    output reg signed [`FC1_ACC_WIDTH-1:0] neuron_out
);
    // 自动生成的查找表函数库，包含 get_L3_n0 到 get_L3_n31
    `include "lut_L3_all.v" 

    // 定义中间查表结果存储阵列
    wire signed [`FC1_LUT_OUT_WIDTH-1:0] lut_vals [209:0];
    
    // --- 并行查表逻辑生成 ---
    genvar i;
    generate
        for (i = 0; i < 210; i = i + 1) begin : gen_luts
            // 提取当前特征点的 4-bit 索引
            wire [3:0] current_idx = flat_indices[(i+1)*4-1 : i*4];
            // 计算全局偏移地址：每个特征点占用 16 个条目
            wire [11:0] addr = i * 16 + current_idx; 
            
            reg signed [`FC1_LUT_OUT_WIDTH-1:0] val;
            
            // 根据 NEURON_ID 选择对应的硬编码查找函数
            // 注意：这些函数由 Python 脚本根据训练好的权重自动生成
            always @(*) begin
                case (NEURON_ID)
                    0:  val = get_L3_n0(addr);
                    1:  val = get_L3_n1(addr);
                    2:  val = get_L3_n2(addr);
                    3:  val = get_L3_n3(addr);
                    4:  val = get_L3_n4(addr);
                    5:  val = get_L3_n5(addr);
                    6:  val = get_L3_n6(addr);
                    7:  val = get_L3_n7(addr);
                    8:  val = get_L3_n8(addr);
                    9:  val = get_L3_n9(addr);
                    10: val = get_L3_n10(addr);
                    11: val = get_L3_n11(addr);
                    12: val = get_L3_n12(addr);
                    13: val = get_L3_n13(addr);
                    14: val = get_L3_n14(addr);
                    15: val = get_L3_n15(addr);
                    16: val = get_L3_n16(addr);
                    17: val = get_L3_n17(addr);
                    18: val = get_L3_n18(addr);
                    19: val = get_L3_n19(addr);
                    20: val = get_L3_n20(addr);
                    21: val = get_L3_n21(addr);
                    22: val = get_L3_n22(addr);
                    23: val = get_L3_n23(addr);
                    24: val = get_L3_n24(addr);
                    25: val = get_L3_n25(addr);
                    26: val = get_L3_n26(addr);
                    27: val = get_L3_n27(addr);
                    28: val = get_L3_n28(addr);
                    29: val = get_L3_n29(addr);
                    30: val = get_L3_n30(addr);
                    31: val = get_L3_n31(addr);
                    default: val = {`FC1_LUT_OUT_WIDTH{1'b0}};
                endcase
            end
            assign lut_vals[i] = val;
        end
    endgenerate

    // --- 累加逻辑 ---
    // 使用组合逻辑实现 210 个特征值的求和，并加上该神经元的偏置项 (Bias)
    // 提示：对于 210 路加法，建议在实际 FPGA 部署时采用 3-4 级流水线加法树以提升时钟频率
    integer j;
    reg signed [`FC1_ACC_WIDTH-1:0] acc_comb;
    
    always @(*) begin
        acc_comb = BIAS_VALUE; // 初始值为偏置项 [cite: 13, 21]
        for (j = 0; j < 210; j = j + 1) begin
            acc_comb = acc_comb + lut_vals[j];
        end
    end

    // 时序输出：将计算结果锁存到输出寄存器
    always @(posedge clk) begin
        neuron_out <= acc_comb;
    end

endmodule