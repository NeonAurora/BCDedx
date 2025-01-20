module bcd_adder_8bit (
    input  wire [7:0] A,
    input  wire [7:0] B,      
    output wire [7:0] SUM_BCD, 
    output wire       CARRY_OUT
);
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

    wire carry_to_upper = carry_lower_raw | carry_lower_nibble;

    wire [3:0] bin_sum_upper;
    wire       carry_upper_raw;

    ripple_adder_4bit add_upper (
        .a   (A[7:4]),
        .b   (B[7:4]),
        .cin (carry_to_upper),
        .sum (bin_sum_upper),
        .cout(carry_upper_raw)
    );

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

    wire final_carry_or_over = (bcd_sum_upper >= 4'd10) | carry_upper_nibble | carry_upper_raw;


    assign SUM_BCD   = { bcd_sum_upper, bcd_sum_lower };
    assign CARRY_OUT = final_carry_or_over;

endmodule
