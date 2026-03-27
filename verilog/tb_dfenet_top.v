`timescale 1ns/1ps
`include "paramter.v"

module tb_dfenet_top;

    // --- 参数定义 ---
    parameter CLK_PERIOD = 10; 
    parameter NUM_TESTS  = 10; 
    parameter TEST_FILE  = "input_vectors_hex.txt";

    // --- 信号定义 ---
    reg clk;
    reg rst_n;
    
    // 匹配顶层 input_indices [359:0] (90个4-bit索引)
    reg [359:0] input_indices_flat;
    reg signed [`RATIO_WIDTH-1:0] x_ratio;
    
    // 匹配输出端口
    wire signed [`OUTPUT_WIDTH-1:0] tap0, tap1, tap2, tap3, tap4;

    // 存储阵列：1行 = 8bit(Ratio) + 360bit(Indices) = 368 bits (对应 92 个十六进制字符)
    reg [367:0] test_vectors [0:NUM_TESTS-1];
    
    integer i;

    // --- 实例化 DUT (必须与你的 TopLevel_DFENet.v 模块名一致) ---
    TopLevel_DFENet u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .input_indices(input_indices_flat), // 传入 360 位拼接信号
        .x_ratio(x_ratio),
        .tap_out_0(tap0),
        .tap_out_1(tap1),
        .tap_out_2(tap2),
        .tap_out_3(tap3),
        .tap_out_4(tap4)
    );

    // --- 时钟生成 ---
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // --- 仿真测试流程 ---
    initial begin
        // 1. 初始化
        rst_n = 0;
        input_indices_flat = 0;
        x_ratio = 0;
        
        // 2. 加载十六进制测试文件
        $readmemh(TEST_FILE, test_vectors);
        
        #(CLK_PERIOD * 10); 
        rst_n = 1; // 释放复位
        #(CLK_PERIOD * 5);

        $display("--------------------------------------------------");
        $display(" 开始 DFENet 硬件仿真 | 32个并行神经元架构 ");
        $display("--------------------------------------------------");

        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            @(negedge clk); // 在时钟下降沿更新数据
            
            // 解析测试向量
            // 假设文件一行数据构造为：{Ratio[7:0], Index89[3:0], ..., Index0[3:0]}
            x_ratio            = test_vectors[i][367:360];
            input_indices_flat = test_vectors[i][359:0];
            
            // 3. 等待流水线延迟
            // 由于有 4/8 路池化和全连接层累加，至少需要 15 个时钟周期数据才能到达输出端
            repeat(15) @(posedge clk); 
            
            #1; // 采样偏移
            $display("[样本 %0d] Ratio: %d", i, $signed(x_ratio));
            $display("    Tap输出 -> T0:%d, T1:%d, T2:%d, T3:%d, T4:%d", 
                     $signed(tap0), $signed(tap1), $signed(tap2), $signed(tap3), $signed(tap4));
            $display("--------------------------------------------------");
        end
        
        #(CLK_PERIOD * 20);
        $display("仿真完成！");
        $finish;
    end

    // 生成波形文件
    initial begin
        $dumpfile("dfenet_sim.vcd");
        $dumpvars(0, tb_dfenet_top);
    end

endmodule