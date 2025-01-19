// File: bcd_subtractor_8bit.v	 

module bcd_subtractor_8bit (
    input  wire [7:0] A,         // two-digit BCD for A
    input  wire [7:0] B,         // two-digit BCD for B
    output wire [7:0] DIFF_BCD,  // two-digit BCD difference (positive magnitude)
    output wire       BORROW_OUT // 1 if (A < B) => negative difference
);

    //------------------------------------------------
    // 1) Raw Subtraction in 8-bit binary: A - B
    //    Actually do A + (~B) + 1 => raw_sub
    //------------------------------------------------
    wire [7:0] b_inverted = ~B;
    wire [7:0] raw_sub;
    wire       raw_cout;  // carry out from the 8-bit add

    ripple_adder_8bit adder_raw (
        .a   (A),
        .b   (b_inverted),
        .cin (1'b1),
        .sum (raw_sub),
        .cout(raw_cout)
    );

    // Interpretation:
    // If raw_cout==0 => A >= B => difference is positive
    // If raw_cout==1 => A < B => difference is negative in 2’s complement

    wire A_less_B = (raw_cout == 1'b1); // If carry out is 1 => A<B in unsigned sense
    // (Counter-intuitive but for A + (~B) + 1, carry==1 => means negative.)

    // We'll separate the code path for positive vs negative results
    // to avoid the "100's complement" confusion and set BORROW_OUT properly.

    //------------------------------------------------
    // 2) Positive case: (A >= B)
    //    Just do normal BCD correction on (A - B) = raw_sub
    //    We expect raw_sub to be a positive decimal in binary form.
    //------------------------------------------------
    wire [7:0] positive_sub_bcd;
    wire       dummy_borrow_pos;
    bcd_sub_pos correction_positive (
        .raw_diff (raw_sub),
        .diff_bcd (positive_sub_bcd),
        .borrow   (dummy_borrow_pos)
    );

    //------------------------------------------------
    // 3) Negative case: (A < B)
    //    The raw_sub is actually the 2's complement
    //    of (B - A). So let's find magnitude by (0x100 - raw_sub),
    //    then do normal BCD correction, set BORROW=1
    //------------------------------------------------
    wire [7:0] magnitude_neg;
    wire       dummy_cout_neg;

    // magnitude = 0x100 - raw_sub = ~raw_sub + 1
    ripple_adder_8bit find_mag (
        .a   (~raw_sub),
        .b   (8'h01),
        .cin (1'b0),
        .sum (magnitude_neg),
        .cout(dummy_cout_neg)
    );

    // Now correct that magnitude in BCD as if it's a positive
    // We re-use the same 'bcd_sub_pos' logic
    wire [7:0] negative_sub_bcd;
    wire       dummy_borrow_neg;
    bcd_sub_pos correction_negative (
        .raw_diff (magnitude_neg),
        .diff_bcd (negative_sub_bcd),
        .borrow   (dummy_borrow_neg)
    );

    // Final outputs chosen by whether A<B
    // If A<B => DIFF_BCD= negative_sub_bcd, BORROW_OUT=1
    // If A>=B => DIFF_BCD= positive_sub_bcd, BORROW_OUT=0
    assign DIFF_BCD   = (A_less_B) ? negative_sub_bcd : positive_sub_bcd;
    assign BORROW_OUT = (A_less_B) ? 1'b1            : 1'b0;

endmodule


//--------------------------------------------------------
// Helper module: bcd_sub_pos
// Corrects an 8-bit *positive* difference in binary into
// normal 2-digit BCD by subtracting 6 from any nibble >9.
// (Equivalent to the "add -6" if nibble>9 approach.)
// Also returns a borrow flag if final upper nibble >=10
//--------------------------------------------------------
module bcd_sub_pos (
    input  wire [7:0] raw_diff,
    output wire [7:0] diff_bcd,
    output wire       borrow
);
    // 1) Correct lower nibble if >9 => subtract 6
    wire lower_need_correction = (raw_diff[3:0] > 4'd9);
    wire [7:0] corr_lower_val  = (lower_need_correction) ? 8'hFA : 8'h00; // -6 in 2's complement

    wire [7:0] corrected_lower;
    wire       cout_lower;
    ripple_adder_8bit corr_l (
        .a   (raw_diff),
        .b   (corr_lower_val),
        .cin (1'b0),
        .sum (corrected_lower),
        .cout(cout_lower)
    );

    // 2) Correct upper nibble if >9 => subtract 6<<4 => 0xA0
    wire upper_need_correction = (corrected_lower[7:4] > 4'd9);
    wire [7:0] corr_upper_val  = (upper_need_correction) ? 8'hA0 : 8'h00;

    wire [7:0] corrected_final;
    wire       cout_upper;
    ripple_adder_8bit corr_u (
        .a   (corrected_lower),
        .b   (corr_upper_val),
        .cin (1'b0),
        .sum (corrected_final),
        .cout(cout_upper)
    );

    // If final upper nibble >= 10 => borrow=1 => means result invalid for 2-digit
    wire nibble_over = (corrected_final[7:4] > 4'd9);
    assign borrow    = nibble_over;

    assign diff_bcd  = corrected_final;
endmodule
