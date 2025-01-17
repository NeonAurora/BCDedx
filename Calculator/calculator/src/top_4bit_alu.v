// File: top_4bit_alu.v		   

module top_4bit_alu (
    input  wire       clk,
    input  wire       rst,
    input  wire [3:0] inA,      // 4-bit input for A
    input  wire [3:0] inB,      // 4-bit input for B
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    input  wire [1:0] op,       // 00=Add, 01=Sub, 10=Mul, 11=Div
    output wire [7:0] led_out,  // 8-bit ALU result
    output wire       flag_out  // carry/borrow/overflow/div0
);

    // Signals
    wire loadA, loadB;
    wire [3:0] regA_out;
    wire [3:0] regB_out;
    wire [7:0] alu_result;
    wire       status;

    // Controller
    controller_2bit controller_inst (
        .btnLoadA(btnLoadA),
        .btnLoadB(btnLoadB),
        .loadA(loadA),
        .loadB(loadB)
    );

    // 4-bit Register for A
    register_4bit regA (
        .clk(clk),
        .rst(rst),
        .load(loadA),
        .d(inA),
        .q(regA_out)
    );

    // 4-bit Register for B
    register_4bit regB (
        .clk(clk),
        .rst(rst),
        .load(loadB),
        .d(inB),
        .q(regB_out)
    );

    // 4-bit ALU
    alu_4bit alu_inst (
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
