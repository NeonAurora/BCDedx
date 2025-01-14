// File: top_2bit_alu.v
`include "register_2bit.v"
`include "alu_2bit.v"
`include "controller_2bit.v"

module top_2bit_alu (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] inA,
    input  wire [1:0] inB,
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    input  wire       op,     // 0 = Add, 1 = Sub
    output wire [2:0] led_out, 
    output wire       carry_borrow
);

    // Internal signals
    wire loadA, loadB;
    wire [1:0] regA_out;
    wire [1:0] regB_out;
    wire [2:0] alu_result;

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
    //  ALU (Add/Sub)
    // -----------------
    alu_2bit alu_inst (
        .a(regA_out),
        .b(regB_out),
        .op(op),                // 0=Add, 1=Sub
        .result(alu_result),
        .carry_borrow(carry_borrow)
    );

    // -----------------
    //  Output (LEDs)
    // -----------------
    assign led_out = alu_result;

endmodule
