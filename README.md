# CNNSE
CNN-Based Smart Equalizer: A Low-Latency and Robust DFE Alternative for Dynamic Physical Environments
This supplementary material includes the released Verilog implementation of the proposed inference path, a sample input file (`input_vectors_hex.txt`), and the decoding rule for interpreting the RTL outputs.

Each input sample in `input_vectors_hex.txt` is composed of one 8-bit signed ratio value and 90 quantized history indices, where each history index is a 4-bit code. These indices are quantized input representations rather than raw waveform voltages.

The RTL output is organized as:
[Ratio, Tap0, Tap1, Tap2, Tap3, Tap4]

The five tap outputs are represented as signed 16-bit two’s-complement integers. Their corresponding floating-point values are recovered as:

ratio_float = signed_int(ratio_hex) / 127
tap_float   = signed_int(tap_hex) / 14224

For example, for the RTL output:
0a 02ab 0107 ff60 ffe1 ffff

the decoded values are:
ratio = 10 / 127 = 0.07874
tap0  = 683 / 14224 = 0.04802
tap1  = 263 / 14224 = 0.01849
tap2  = -160 / 14224 = -0.01125
tap3  = -31 / 14224 = -0.00218
tap4  = -1 / 14224 = -0.00007
