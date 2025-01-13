// File: top_2bit_adder.v
`include "register_2bit.v"
`include "adder_2bit.v"
`include "controller_2bit.v"

module top_2bit_adder (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] inA,
    input  wire [1:0] inB,
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    output wire [2:0] led_out  // 3-bit output to show the sum
);

    // Internal signals
    wire loadA, loadB;
    wire [1:0] regA_out;
    wire [1:0] regB_out;
    wire [2:0] sum;

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
    //  2-bit Adder
    // -----------------
    adder_2bit adder_inst (
        .a(regA_out),
        .b(regB_out),
        .sum(sum)
    );

    // -----------------
    //  Output (LEDs)
    // -----------------
    assign led_out = sum;

endmodule
