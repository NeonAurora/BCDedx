module bcd_subtractor_8bit_eac (
    input  wire [7:0] A,
    input  wire [7:0] B,  
    output wire [7:0] DIFF_BCD, 
    output wire       EAC,     
    output wire [7:0] debug_Adder1 
);

    wire [7:0] compB = ~B; 

    
    wire [3:0] sum_lsb;
    wire       carry_lsb;
    bcd_adder_4bit adder1_lsb (
        .A(A[3:0]),
        .B(compB[3:0]),
        .cin(1'b1),   
        .sum(sum_lsb),
        .cout(carry_lsb)
    );

   
    wire [3:0] sum_msb;
    wire       carry_msb;
    bcd_adder_4bit adder1_msb (
        .A(A[7:4]),
        .B(compB[7:4]),
        .cin(carry_lsb),  
        .sum(sum_msb),
        .cout(carry_msb)
    );

    
    wire [7:0] sum_Adder1 = { sum_msb, sum_lsb };

    
    assign EAC = carry_msb;

   
    assign debug_Adder1 = sum_Adder1;

    
    wire [3:0] final_lsb;
    wire       carry2_lsb;

    second_pass_logic nibble0_pass2 (
        .group_in  (sum_lsb),
        .carry_in  (carry_lsb),
        .EAC       (EAC),
        .group_out (final_lsb),
        .cout      (carry2_lsb)
    );
									  
    wire [3:0] final_msb;
    wire       carry2_msb;

    second_pass_logic nibble1_pass2 (
        .group_in  (sum_msb),
        .carry_in  (carry2_lsb), 
        .EAC       (EAC),
        .group_out (final_msb),
        .cout      (carry2_msb)
    );

    assign DIFF_BCD = { final_msb, final_lsb };	   

endmodule


module second_pass_logic (
    input  wire [3:0] group_in,
    input  wire       carry_in,
    input  wire       EAC,
    output wire [3:0] group_out,
    output wire       cout
);
    
    wire [3:0] xfer_val = (EAC == 1'b1) ? group_in : (~group_in);

   
    wire add_10 = ((EAC == 1'b1) && (carry_in == 1'b0)) ||
                  ((EAC == 1'b0) && (carry_in == 1'b1));

    wire [3:0] add_nibble = add_10 ? 4'b1010 : 4'b0000;

   
    wire [3:0] sum_nibble;
    wire       c_out;
    bcd_adder_4bit pass2_nibble_adder (
        .A(xfer_val),
        .B(add_nibble),
        .cin(1'b0),
        .sum(sum_nibble),
        .cout(c_out)
    );

    assign group_out = sum_nibble;
    assign cout      = c_out;
endmodule



module bcd_adder_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire c1, c2, c3;

    full_adder fa0 ( .a(A[0]), .b(B[0]), .cin(cin),  .sum(sum[0]), .cout(c1) );
    full_adder fa1 ( .a(A[1]), .b(B[1]), .cin(c1),   .sum(sum[1]), .cout(c2) );
    full_adder fa2 ( .a(A[2]), .b(B[2]), .cin(c2),   .sum(sum[2]), .cout(c3) );
    full_adder fa3 ( .a(A[3]), .b(B[3]), .cin(c3),   .sum(sum[3]), .cout(cout));
endmodule	
