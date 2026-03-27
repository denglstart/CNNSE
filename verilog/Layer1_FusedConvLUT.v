`include "paramter.v"

module layer1_fused_rom #(
    parameter CHANNEL_ID = 0, 
    parameter TIME_STEP = 0   
)(
    input  wire clk,
    input  wire [`LUT1_ADDR_WIDTH-1:0] addr_idx,
    output reg  signed [`LUT1_OUT_WIDTH-1:0] val_out
);

    // 【修正】必须放在 module 内部！
    `include "lut_L1_all.v"

    always @(posedge clk) begin
        case (CHANNEL_ID)
            0: val_out <= get_lut_ch0(addr_idx);
            1: val_out <= get_lut_ch1(addr_idx);
            2: val_out <= get_lut_ch2(addr_idx);
            3: val_out <= get_lut_ch3(addr_idx);
            4: val_out <= get_lut_ch4(addr_idx);
            default: val_out <= 6'sd0;
        endcase
    end

endmodule