// File: bcd_adder_4bit.v

module bcd_adder_4bit (
    input  wire [3:0] a,          // BCD digit A (0-9)
    input  wire [3:0] b,          // BCD digit B (0-9)
    output wire [3:0] sum_bcd,    // corrected BCD sum (0-9)
    output wire       carry_out   // 1 if result >= 10 decimal
);

    wire [3:0] sum_bin;
    wire       cout_bin;

    // 1) First, add as pure binary
    ripple_adder_4bit bin_adder (
        .a   (a),
        .b   (b),
        .cin (1'b0),
        .sum (sum_bin),
        .cout(cout_bin)
    );

    // Now check if correction is needed.
    // Condition: if sum_bin > 9 (>= 1010) or carry out is 1, we add 6 (0110).
    wire correction_needed = cout_bin | (sum_bin >= 4'b1010);

    // We’ll add 6 if correction_needed==1
    // 6 = 0110 in binary
    wire [3:0] correction = correction_needed ? 4'b0110 : 4'b0000;

    // 2) Add correction
    wire [3:0] sum_corrected;
    wire       cout_corrected;

    ripple_adder_4bit corr_adder (
        .a   (sum_bin),
        .b   (correction),
        .cin (1'b0),
        .sum (sum_corrected),
        .cout(cout_corrected)
    );

    // Final sum in BCD
    assign sum_bcd   = sum_corrected;
    // The "carry_out" from a single-digit BCD addition means we exceeded 9, 
    // or had a previous carry, or the correction caused an extra carry.
    // So overall carry out for BCD is the OR of correction_needed and 
    // the final adder’s carry out. This depends on your convention.
    assign carry_out = cout_corrected | correction_needed;

endmodule
