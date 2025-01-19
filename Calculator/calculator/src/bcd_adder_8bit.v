// File: bcd_adder_8bit.v

module bcd_adder_8bit (
    input  wire [7:0] A,       // two-digit BCD for A: [7:4] upper, [3:0] lower
    input  wire [7:0] B,       // two-digit BCD for B
    output wire [7:0] SUM_BCD, // corrected two-digit BCD result
    output wire       CARRY_OUT // 1 if result >= 100 decimal
);
    // ------------------------------------------------
    // 1) LOWER NIBBLES: A[3:0] + B[3:0] (4-bit add)
    // ------------------------------------------------
    wire [3:0] bin_sum_lower;
    wire       carry_lower_raw;

    ripple_adder_4bit add_lower (
        .a   (A[3:0]),
        .b   (B[3:0]),
        .cin (1'b0),
        .sum (bin_sum_lower),
        .cout(carry_lower_raw)
    );

    wire [4:0] sum_lower_5bit = {carry_lower_raw, bin_sum_lower};  // 5 bits
	wire lower_correction_needed = (sum_lower_5bit >= 5'd10);

    wire [3:0] correction_lower_value  = lower_correction_needed ? 4'd6 : 4'd0;

    wire [3:0] bcd_sum_lower;
    wire       carry_lower_nibble;

    ripple_adder_4bit corr_lower (
        .a   (bin_sum_lower),
        .b   (correction_lower_value),
        .cin (1'b0),
        .sum (bcd_sum_lower),
        .cout(carry_lower_nibble)
    );

    // The total carry-out from the lower nibble stage is
    // carry_lower_raw (binary add of nibble) OR carry_lower_nibble (from correction)
    // but actually we often only track 'carry_lower_nibble'
    // because if we do 7+9=16 => bin_sum_lower=0x0, carry_lower_raw=1, then adding +6 => ...
    // It's simpler to combine them carefully:
    wire carry_to_upper = carry_lower_raw | carry_lower_nibble;

    // ------------------------------------------------
    // 2) UPPER NIBBLES: A[7:4] + B[7:4] + carry_to_upper
    // ------------------------------------------------
    wire [3:0] bin_sum_upper;
    wire       carry_upper_raw;

    ripple_adder_4bit add_upper (
        .a   (A[7:4]),
        .b   (B[7:4]),
        .cin (carry_to_upper),  // The decimal carry from lower nibble
        .sum (bin_sum_upper),
        .cout(carry_upper_raw)
    );

    // BCD correction on upper nibble if >= 10
    wire       upper_correction_needed = (bin_sum_upper >= 4'd10);
    wire [3:0] correction_upper_value  = upper_correction_needed ? 4'd6 : 4'd0;

    wire [3:0] bcd_sum_upper;
    wire       carry_upper_nibble;

    ripple_adder_4bit corr_upper (
        .a   (bin_sum_upper),
        .b   (correction_upper_value),
        .cin (1'b0),
        .sum (bcd_sum_upper),
        .cout(carry_upper_nibble)
    );

    // If the final upper nibble is >= 10 or we have a final nibble carry,
    // that means the sum >= 100 decimal
    wire final_carry_or_over = (bcd_sum_upper >= 4'd10) | carry_upper_nibble | carry_upper_raw;

    // ------------------------------------------------
    // 3) Combine results
    // ------------------------------------------------
    assign SUM_BCD   = { bcd_sum_upper, bcd_sum_lower };
    assign CARRY_OUT = final_carry_or_over;

endmodule
