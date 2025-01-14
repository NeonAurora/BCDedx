// File: top_2bit_alu_mult.v	  

module top_2bit_alu_mult (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] inA,
    input  wire [1:0] inB,
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    input  wire [1:0] op,    // 00=Add, 01=Sub, 10=Mul
    output wire [3:0] led_out, 
    output wire       flag_out // carry/borrow/overflow
);

    // Internal signals
    wire loadA, loadB;
    wire [1:0] regA_out;
    wire [1:0] regB_out;
    wire [3:0] alu_result;
    wire       status;

    // -----------------
    //  Controller
    // -----------------
    controller_2bit controller_inst (
        .btnLoadA(btnLoadA),
        .btnLoadB(btnLoadB),
        .loadA(loadA),
        .loadB(loadB)
    );

    // -----------------
    //  Registers
    // -----------------
    register_2bit regA (
        .clk(clk),
        .rst(rst),
        .load(loadA),
        .d(inA),
        .q(regA_out)
    );

    register_2bit regB (
        .clk(clk),
        .rst(rst),
        .load(loadB),
        .d(inB),
        .q(regB_out)
    );

    // -----------------
    //  ALU (Add/Sub/Multiply)
    // -----------------
    alu_2bit alu_inst (
        .a(regA_out),
        .b(regB_out),
        .op(op),         // 00=Add, 01=Sub, 10=Mul
        .result(alu_result),
        .status(status)  // carry/borrow/overflow
    );

    // -----------------
    //  Output
    // -----------------
    assign led_out = alu_result;
    assign flag_out = status;

endmodule
