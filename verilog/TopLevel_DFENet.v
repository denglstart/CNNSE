`include "paramter.v"

module TopLevel_DFENet (
    input  wire clk,
    input  wire rst_n,
    // 输入：90个连续符号的展平4-bit量化索引 (360 bit)
    input  wire [359:0] input_indices,
    // 输入：全局能量比率特征 x_ratio
    input  wire signed [`RATIO_WIDTH-1:0] x_ratio,
    
    // 输出：5个抽头系数
    output wire signed [`OUTPUT_WIDTH-1:0] tap_out_0,
    output wire signed [`OUTPUT_WIDTH-1:0] tap_out_1,
    output wire signed [`OUTPUT_WIDTH-1:0] tap_out_2,
    output wire signed [`OUTPUT_WIDTH-1:0] tap_out_3,
    output wire signed [`OUTPUT_WIDTH-1:0] tap_out_4
);

    // =========================================================================
    // 0. 输入解包 (Unpacking)
    // =========================================================================
    // 将 360-bit 展平总线转为 90 个 4-bit 数组方便后续索引访问
    wire [3:0] input_array [89:0];
    genvar idx;
    generate
        for (idx = 0; idx < 90; idx = idx + 1) begin : unpack_inputs
            assign input_array[idx] = input_indices[(idx*4) +: 4];
        end
    endgenerate

    // =========================================================================
    // 1. Branch 1 逻辑 (historyLen=20, Cout=2, Pool=1) -> 40 Features
    // =========================================================================
    wire signed [`LUT1_OUT_WIDTH-1:0] b1_raw [1:0][19:0];
    wire [159:0] b1_flat; // 40个4-bit特征 = 160 bits
    
    genvar b1_c, b1_k;
    generate
        for (b1_c = 0; b1_c < 2; b1_c = b1_c + 1) begin : gen_b1_channels
            for (b1_k = 0; b1_k < 20; b1_k = b1_k + 1) begin : gen_b1_luts
                layer1_fused_rom #(.CHANNEL_ID(b1_c)) u_b1_rom (
                    .clk(clk),
                    .addr_idx(input_array[b1_k]), // 修正：使用解包后的数组
                    .val_out(b1_raw[b1_c][b1_k])
                );
                requantizer u_b1_req (
                    .pool_val(b1_raw[b1_c][b1_k]),
                    .lut_idx(b1_flat[(b1_c*20+b1_k+1)*4-1 : (b1_c*20+b1_k)*4])
                );
            end
        end
    endgenerate

    // =========================================================================
    // 2. Branch 2 逻辑 (historyLen=60, Cout=6, Pool=4) -> 90 Features
    // =========================================================================
    wire signed [`LUT1_OUT_WIDTH-1:0] b2_raw [5:0][59:0];
    wire signed [`POOL_OUT_WIDTH-1:0] b2_pooled [5:0][14:0];
    wire [359:0] b2_flat; // 90个4-bit特征 = 360 bits

    genvar b2_c, b2_p, b2_k;
    generate
        for (b2_c = 0; b2_c < 6; b2_c = b2_c + 1) begin : gen_b2_channels
            for (b2_k = 0; b2_k < 60; b2_k = b2_k + 1) begin : gen_b2_luts
                layer1_fused_rom #(.CHANNEL_ID(b2_c)) u_b2_rom (
                    .clk(clk),
                    .addr_idx(input_array[b2_k]), // 修正：使用解包后的数组
                    .val_out(b2_raw[b2_c][b2_k])
                );
            end
            for (b2_p = 0; b2_p < 15; b2_p = b2_p + 1) begin : gen_b2_pools
                layer2_pooling #(.POOL_SIZE(4)) u_b2_pool (
                    .clk(clk),
                    .in_bus({b2_raw[b2_c][b2_p*4+3], b2_raw[b2_c][b2_p*4+2], 
                             b2_raw[b2_c][b2_p*4+1], b2_raw[b2_c][b2_p*4+0]}),
                    .pool_out(b2_pooled[b2_c][b2_p])
                );
                requantizer u_b2_req (
                    .pool_val(b2_pooled[b2_c][b2_p]),
                    .lut_idx(b2_flat[(b2_c*15+b2_p+1)*4-1 : (b2_c*15+b2_p)*4])
                );
            end
        end
    endgenerate

    // =========================================================================
    // 3. Branch 3 逻辑 (historyLen=80, Cout=8, Pool=8) -> 80 Features
    // =========================================================================
    wire signed [`LUT1_OUT_WIDTH-1:0] b3_raw [7:0][79:0];
    wire signed [`POOL_OUT_WIDTH-1:0] b3_pooled [7:0][9:0];
    wire [319:0] b3_flat; // 80个4-bit特征 = 320 bits

    genvar b3_c, b3_p, b3_k;
    generate
        for (b3_c = 0; b3_c < 8; b3_c = b3_c + 1) begin : gen_b3_channels
            for (b3_k = 0; b3_k < 80; b3_k = b3_k + 1) begin : gen_b3_luts
                layer1_fused_rom #(.CHANNEL_ID(b3_c)) u_b3_rom (
                    .clk(clk),
                    .addr_idx(input_array[b3_k]), // 修正：使用解包后的数组
                    .val_out(b3_raw[b3_c][b3_k])
                );
            end
            for (b3_p = 0; b3_p < 10; b3_p = b3_p + 1) begin : gen_b3_pools
                layer2_pooling #(.POOL_SIZE(8)) u_b3_pool (
                    .clk(clk),
                    .in_bus({b3_raw[b3_c][b3_p*8+7], b3_raw[b3_c][b3_p*8+6], 
                             b3_raw[b3_c][b3_p*8+5], b3_raw[b3_c][b3_p*8+4],
                             b3_raw[b3_c][b3_p*8+3], b3_raw[b3_c][b3_p*8+2], 
                             b3_raw[b3_c][b3_p*8+1], b3_raw[b3_c][b3_p*8+0]}),
                    .pool_out(b3_pooled[b3_c][b3_p])
                );
                requantizer u_b3_req (
                    .pool_val(b3_pooled[b3_c][b3_p]),
                    .lut_idx(b3_flat[(b3_c*10+b3_p+1)*4-1 : (b3_c*10+b3_p)*4])
                );
            end
        end
    endgenerate

    // =========================================================================
    // 4. 特征拼接与全连接层 (Layer 3: 32 Neurons)
    // =========================================================================
    // 总特征维度 = 40 (B1) + 90 (B2) + 80 (B3) = 210 (总 840 bit)
    wire [839:0] flat_indices_bus = {b3_flat, b2_flat, b1_flat};
    wire signed [`FC1_ACC_WIDTH-1:0] neuron_outs [31:0];

    // 获取导出的 Bias 数组矢量 (需在导出脚本中生成 L3_BIAS_ALL)
    `include "lut_L3_all.v" 

    genvar n;
    generate
        for (n = 0; n < 32; n = n + 1) begin : gen_layer3
            layer3_neuron_pe #(
                .NEURON_ID(n),
                // 推荐写法：使用 L3_BIAS_ALL 矢量进行位裁切，避开复杂的三元运算符
                .BIAS_VALUE(L3_BIAS_ALL[(n*16) +: 16]) 
            ) u_pe (
                .clk(clk),
                .flat_indices(flat_indices_bus),
                .neuron_out(neuron_outs[n])
            );
        end
    endgenerate

    // =========================================================================
    // 5. 输出层 (Layer 4)
    // =========================================================================
    layer4_fc2 u_fc2_out (
        .clk(clk),
        .feat_0(neuron_outs[0]),   .feat_1(neuron_outs[1]),   .feat_2(neuron_outs[2]),   .feat_3(neuron_outs[3]),
        .feat_4(neuron_outs[4]),   .feat_5(neuron_outs[5]),   .feat_6(neuron_outs[6]),   .feat_7(neuron_outs[7]),
        .feat_8(neuron_outs[8]),   .feat_9(neuron_outs[9]),   .feat_10(neuron_outs[10]), .feat_11(neuron_outs[11]),
        .feat_12(neuron_outs[12]), .feat_13(neuron_outs[13]), .feat_14(neuron_outs[14]), .feat_15(neuron_outs[15]),
        .feat_16(neuron_outs[16]), .feat_17(neuron_outs[17]), .feat_18(neuron_outs[18]), .feat_19(neuron_outs[19]),
        .feat_20(neuron_outs[20]), .feat_21(neuron_outs[21]), .feat_22(neuron_outs[22]), .feat_23(neuron_outs[23]),
        .feat_24(neuron_outs[24]), .feat_25(neuron_outs[25]), .feat_26(neuron_outs[26]), .feat_27(neuron_outs[27]),
        .feat_28(neuron_outs[28]), .feat_29(neuron_outs[29]), .feat_30(neuron_outs[30]), .feat_31(neuron_outs[31]),
        .ratio_in(x_ratio),
        .tap_out_0(tap_out_0), .tap_out_1(tap_out_1), .tap_out_2(tap_out_2), 
        .tap_out_3(tap_out_3), .tap_out_4(tap_out_4)
    );

endmodule