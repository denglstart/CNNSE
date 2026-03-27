`include "paramter.v"

module layer4_fc2 (
    input  wire clk,
    // 接收来自 Layer3 的 32 个神经元输出特征
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_0,  feat_1,  feat_2,  feat_3,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_4,  feat_5,  feat_6,  feat_7,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_8,  feat_9,  feat_10, feat_11,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_12, feat_13, feat_14, feat_15,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_16, feat_17, feat_18, feat_19,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_20, feat_21, feat_22, feat_23,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_24, feat_25, feat_26, feat_27,
    input  wire signed [`FC1_ACC_WIDTH-1:0] feat_28, feat_29, feat_30, feat_31,
    
    // 接收全局能量比例特征 x_ratio
    input  wire signed [`RATIO_WIDTH-1:0]   ratio_in,
    
    // 输出 5 个 DFE Tap 抽头系数
    output reg signed [`OUTPUT_WIDTH-1:0]   tap_out_0,
    output reg signed [`OUTPUT_WIDTH-1:0]   tap_out_1,
    output reg signed [`OUTPUT_WIDTH-1:0]   tap_out_2,
    output reg signed [`OUTPUT_WIDTH-1:0]   tap_out_3,
    output reg signed [`OUTPUT_WIDTH-1:0]   tap_out_4
);

    // 包含由导出脚本生成的 165 个权重参数（L4_W_0_0 到 L4_W_4_32）和 5 个偏置（L4_B_0 到 L4_B_4）
    `include "layer4_params.v" 

    // 为了提高运行频率，建议在always块中使用多级中间变量或加法树
    // 此处展示经过扩展的完整乘加逻辑
    always @(posedge clk) begin
        // --- Tap 0 计算 ---
        tap_out_0 <= (feat_0  * L4_W_0_0 ) + (feat_1  * L4_W_0_1 ) + (feat_2  * L4_W_0_2 ) + (feat_3  * L4_W_0_3 ) +
                     (feat_4  * L4_W_0_4 ) + (feat_5  * L4_W_0_5 ) + (feat_6  * L4_W_0_6 ) + (feat_7  * L4_W_0_7 ) +
                     (feat_8  * L4_W_0_8 ) + (feat_9  * L4_W_0_9 ) + (feat_10 * L4_W_0_10) + (feat_11 * L4_W_0_11) +
                     (feat_12 * L4_W_0_12) + (feat_13 * L4_W_0_13) + (feat_14 * L4_W_0_14) + (feat_15 * L4_W_0_15) +
                     (feat_16 * L4_W_0_16) + (feat_17 * L4_W_0_17) + (feat_18 * L4_W_0_18) + (feat_19 * L4_W_0_19) +
                     (feat_20 * L4_W_0_20) + (feat_21 * L4_W_0_21) + (feat_22 * L4_W_0_22) + (feat_23 * L4_W_0_23) +
                     (feat_24 * L4_W_0_24) + (feat_25 * L4_W_0_25) + (feat_26 * L4_W_0_26) + (feat_27 * L4_W_0_27) +
                     (feat_28 * L4_W_0_28) + (feat_29 * L4_W_0_29) + (feat_30 * L4_W_0_30) + (feat_31 * L4_W_0_31) +
                     (ratio_in * L4_W_0_32) + L4_B_0;

        // --- Tap 1 计算 ---
        tap_out_1 <= (feat_0  * L4_W_1_0 ) + (feat_1  * L4_W_1_1 ) + (feat_2  * L4_W_1_2 ) + (feat_3  * L4_W_1_3 ) +
                     (feat_4  * L4_W_1_4 ) + (feat_5  * L4_W_1_5 ) + (feat_6  * L4_W_1_6 ) + (feat_7  * L4_W_1_7 ) +
                     (feat_8  * L4_W_1_8 ) + (feat_9  * L4_W_1_9 ) + (feat_10 * L4_W_1_10) + (feat_11 * L4_W_1_11) +
                     (feat_12 * L4_W_1_12) + (feat_13 * L4_W_1_13) + (feat_14 * L4_W_1_14) + (feat_15 * L4_W_1_15) +
                     (feat_16 * L4_W_1_16) + (feat_17 * L4_W_1_17) + (feat_18 * L4_W_1_18) + (feat_19 * L4_W_1_19) +
                     (feat_20 * L4_W_1_20) + (feat_21 * L4_W_1_21) + (feat_22 * L4_W_1_22) + (feat_23 * L4_W_1_23) +
                     (feat_24 * L4_W_1_24) + (feat_25 * L4_W_1_25) + (feat_26 * L4_W_1_26) + (feat_27 * L4_W_1_27) +
                     (feat_28 * L4_W_1_28) + (feat_29 * L4_W_1_29) + (feat_30 * L4_W_1_30) + (feat_31 * L4_W_1_31) +
                     (ratio_in * L4_W_1_32) + L4_B_1;

        // --- Tap 2 计算 ---
        tap_out_2 <= (feat_0  * L4_W_2_0 ) + (feat_1  * L4_W_2_1 ) + (feat_2  * L4_W_2_2 ) + (feat_3  * L4_W_2_3 ) +
                     (feat_4  * L4_W_2_4 ) + (feat_5  * L4_W_2_5 ) + (feat_6  * L4_W_2_6 ) + (feat_7  * L4_W_2_7 ) +
                     (feat_8  * L4_W_2_8 ) + (feat_9  * L4_W_2_9 ) + (feat_10 * L4_W_2_10) + (feat_11 * L4_W_2_11) +
                     (feat_12 * L4_W_2_12) + (feat_13 * L4_W_2_13) + (feat_14 * L4_W_2_14) + (feat_15 * L4_W_2_15) +
                     (feat_16 * L4_W_2_16) + (feat_17 * L4_W_2_17) + (feat_18 * L4_W_2_18) + (feat_19 * L4_W_2_19) +
                     (feat_20 * L4_W_2_20) + (feat_21 * L4_W_2_21) + (feat_22 * L4_W_2_22) + (feat_23 * L4_W_2_23) +
                     (feat_24 * L4_W_2_24) + (feat_25 * L4_W_2_25) + (feat_26 * L4_W_2_26) + (feat_27 * L4_W_2_27) +
                     (feat_28 * L4_W_2_28) + (feat_29 * L4_W_2_29) + (feat_30 * L4_W_2_30) + (feat_31 * L4_W_2_31) +
                     (ratio_in * L4_W_2_32) + L4_B_2;

        // --- Tap 3 计算 ---
        tap_out_3 <= (feat_0  * L4_W_3_0 ) + (feat_1  * L4_W_3_1 ) + (feat_2  * L4_W_3_2 ) + (feat_3  * L4_W_3_3 ) +
                     (feat_4  * L4_W_3_4 ) + (feat_5  * L4_W_3_5 ) + (feat_6  * L4_W_3_6 ) + (feat_7  * L4_W_3_7 ) +
                     (feat_8  * L4_W_3_8 ) + (feat_9  * L4_W_3_9 ) + (feat_10 * L4_W_3_10) + (feat_11 * L4_W_3_11) +
                     (feat_12 * L4_W_3_12) + (feat_13 * L4_W_3_13) + (feat_14 * L4_W_3_14) + (feat_15 * L4_W_3_15) +
                     (feat_16 * L4_W_3_16) + (feat_17 * L4_W_3_17) + (feat_18 * L4_W_3_18) + (feat_19 * L4_W_3_19) +
                     (feat_20 * L4_W_3_20) + (feat_21 * L4_W_3_21) + (feat_22 * L4_W_3_22) + (feat_23 * L4_W_3_23) +
                     (feat_24 * L4_W_3_24) + (feat_25 * L4_W_3_25) + (feat_26 * L4_W_3_26) + (feat_27 * L4_W_3_27) +
                     (feat_28 * L4_W_3_28) + (feat_29 * L4_W_3_29) + (feat_30 * L4_W_3_30) + (feat_31 * L4_W_3_31) +
                     (ratio_in * L4_W_3_32) + L4_B_3;

        // --- Tap 4 计算 ---
        tap_out_4 <= (feat_0  * L4_W_4_0 ) + (feat_1  * L4_W_4_1 ) + (feat_2  * L4_W_4_2 ) + (feat_3  * L4_W_4_3 ) +
                     (feat_4  * L4_W_4_4 ) + (feat_5  * L4_W_4_5 ) + (feat_6  * L4_W_4_6 ) + (feat_7  * L4_W_4_7 ) +
                     (feat_8  * L4_W_4_8 ) + (feat_9  * L4_W_4_9 ) + (feat_10 * L4_W_4_10) + (feat_11 * L4_W_4_11) +
                     (feat_12 * L4_W_4_12) + (feat_13 * L4_W_4_13) + (feat_14 * L4_W_4_14) + (feat_15 * L4_W_4_15) +
                     (feat_16 * L4_W_4_16) + (feat_17 * L4_W_4_17) + (feat_18 * L4_W_4_18) + (feat_19 * L4_W_4_19) +
                     (feat_20 * L4_W_4_20) + (feat_21 * L4_W_4_21) + (feat_22 * L4_W_4_22) + (feat_23 * L4_W_4_23) +
                     (feat_24 * L4_W_4_24) + (feat_25 * L4_W_4_25) + (feat_26 * L4_W_4_26) + (feat_27 * L4_W_4_27) +
                     (feat_28 * L4_W_4_28) + (feat_29 * L4_W_4_29) + (feat_30 * L4_W_4_30) + (feat_31 * L4_W_4_31) +
                     (ratio_in * L4_W_4_32) + L4_B_4;
    end

endmodule