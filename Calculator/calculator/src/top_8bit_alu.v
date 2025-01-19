// File: top_8bit_alu.v	   

module top_8bit_alu (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] inA,      // 8-bit input for A
    input  wire [7:0] inB,      // 8-bit input for B
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    input  wire [1:0] op,       // 00=Add, 01=Sub, 10=Mul, 11=Div
    output wire [15:0] led_out, // 16-bit ALU result
    output wire        flag_out // carry/borrow/overflow/div0
);

    // Internal signals
    wire loadA_sig, loadB_sig;
    wire [7:0] regA_out;
    wire [7:0] regB_out;
    wire [15:0] alu_result;
    wire        status;

    // Controller (unchanged)
    controller_2bit controller_inst (
        .btnLoadA(btnLoadA),
        .btnLoadB(btnLoadB),
        .loadA(loadA_sig),
        .loadB(loadB_sig)
    );

    // 8-bit Register A
    register_8bit regA (
        .clk(clk),
        .rst(rst),
        .load(loadA_sig),
        .d(inA),
        .q(regA_out)
    );

    // 8-bit Register B
    register_8bit regB (
        .clk(clk),
        .rst(rst),
        .load(loadB_sig),
        .d(inB),
        .q(regB_out)
    );

    // 8-bit ALU
    alu_8bit alu_inst (
        .a(regA_out),
        .b(regB_out),
        .op(op),
        .result(alu_result),
        .status(status)
    );

    // Outputs
    assign led_out  = alu_result;
    assign flag_out = status;

endmodule
