 

module bcd_subtractor_8bit (
    input  wire [7:0] A,         
    input  wire [7:0] B,        
    output wire [7:0] DIFF_BCD,  
    output wire       BORROW_OUT 
);

    
    wire [7:0] b_inverted = ~B;
    wire [7:0] raw_sub;
    wire       raw_cout;  

    ripple_adder_8bit adder_raw (
        .a   (A),
        .b   (b_inverted),
        .cin (1'b1),
        .sum (raw_sub),
        .cout(raw_cout)
    );

   

    wire A_less_B = (raw_cout == 1'b1); 
    
    wire [7:0] positive_sub_bcd;
    wire       dummy_borrow_pos;
    bcd_sub_pos correction_positive (
        .raw_diff (raw_sub),
        .diff_bcd (positive_sub_bcd),
        .borrow   (dummy_borrow_pos)
    );

    
    wire [7:0] magnitude_neg;
    wire       dummy_cout_neg;

    ripple_adder_8bit find_mag (
        .a   (~raw_sub),
        .b   (8'h01),
        .cin (1'b0),
        .sum (magnitude_neg),
        .cout(dummy_cout_neg)
    );

   
    wire [7:0] negative_sub_bcd;
    wire       dummy_borrow_neg;
    bcd_sub_pos correction_negative (
        .raw_diff (magnitude_neg),
        .diff_bcd (negative_sub_bcd),
        .borrow   (dummy_borrow_neg)
    );

    
    assign DIFF_BCD   = (A_less_B) ? negative_sub_bcd : positive_sub_bcd;
    assign BORROW_OUT = (A_less_B) ? 1'b1            : 1'b0;

endmodule



module bcd_sub_pos (
    input  wire [7:0] raw_diff,
    output wire [7:0] diff_bcd,
    output wire       borrow
);
    
    wire lower_need_correction = (raw_diff[3:0] > 4'd9);
    wire [7:0] corr_lower_val  = (lower_need_correction) ? 8'hFA : 8'h00; 

    wire [7:0] corrected_lower;
    wire       cout_lower;
    ripple_adder_8bit corr_l (
        .a   (raw_diff),
        .b   (corr_lower_val),
        .cin (1'b0),
        .sum (corrected_lower),
        .cout(cout_lower)
    );
														   
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
																				  
    wire nibble_over = (corrected_final[7:4] > 4'd9);
    assign borrow    = nibble_over;

    assign diff_bcd  = corrected_final;
endmodule
