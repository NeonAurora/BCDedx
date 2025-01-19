// File: mul_8bit_logic.v
// Pure logic 8-bit multiply => 16-bit result
// using shift-and-add partial products + 16-bit ripple adders.

module mul_8bit_logic (
    input  wire [7:0] A,
    input  wire [7:0] B,
    output wire [15:0] product
); 

    wire [15:0] p0 = B[0] ? {8'b0, A          } : 16'b0;
    wire [15:0] p1 = B[1] ? {7'b0, A, 1'b0    } : 16'b0;
    wire [15:0] p2 = B[2] ? {6'b0, A, 2'b0    } : 16'b0;
    wire [15:0] p3 = B[3] ? {5'b0, A, 3'b0    } : 16'b0;
    wire [15:0] p4 = B[4] ? {4'b0, A, 4'b0    } : 16'b0;
    wire [15:0] p5 = B[5] ? {3'b0, A, 5'b0    } : 16'b0;
    wire [15:0] p6 = B[6] ? {2'b0, A, 6'b0    } : 16'b0;
    wire [15:0] p7 = B[7] ? {1'b0, A, 7'b0    } : 16'b0;

    // 2) Sum them all up with a chain of 16-bit adders
    wire [15:0] sum_01, sum_02, sum_03, sum_04, sum_05, sum_06, sum_07;
    wire c01, c02, c03, c04, c05, c06, c07;

    // partial0 + partial1
    ripple_adder_16bit add01 (
        .a   (p0),
        .b   (p1),
        .cin (1'b0),
        .sum (sum_01),
        .cout(c01)
    );

    // sum_01 + partial2
    ripple_adder_16bit add02 (
        .a   (sum_01),
        .b   (p2),
        .cin (1'b0),
        .sum (sum_02),
        .cout(c02)
    );

    // sum_02 + partial3
    ripple_adder_16bit add03 (
        .a   (sum_02),
        .b   (p3),
        .cin (1'b0),
        .sum (sum_03),
        .cout(c03)
    );

    // sum_03 + partial4
    ripple_adder_16bit add04 (
        .a   (sum_03),
        .b   (p4),
        .cin (1'b0),
        .sum (sum_04),
        .cout(c04)
    );

    // sum_04 + partial5
    ripple_adder_16bit add05 (
        .a   (sum_04),
        .b   (p5),
        .cin (1'b0),
        .sum (sum_05),
        .cout(c05)
    );

    // sum_05 + partial6
    ripple_adder_16bit add06 (
        .a   (sum_05),
        .b   (p6),
        .cin (1'b0),
        .sum (sum_06),
        .cout(c06)
    );

    // sum_06 + partial7
    ripple_adder_16bit add07 (
        .a   (sum_06),
        .b   (p7),
        .cin (1'b0),
        .sum (sum_07),
        .cout(c07)
    );

    // final result
    assign product = sum_07;

endmodule
