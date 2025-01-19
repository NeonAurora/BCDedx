// File: bcd_subtractor_8bit_eac.v
// Example BCD subtraction by "1's complement + EAC" method, for 8 bits (2 nibbles). 

module bcd_subtractor_8bit_eac (
    input  wire [7:0] A,  // 8-bit BCD for minuend  (two nibbles)
    input  wire [7:0] B,  // 8-bit BCD for subtrahend
    output wire [7:0] DIFF_BCD, // final 8-bit BCD difference
    output wire       EAC,      // end-around-carry: 1 => positive, 0 => negative
    output wire [7:0] debug_Adder1 // optional debug: the "Adder1" raw result
);

    //---------------------------------------------------
    // 1) 1's complement of subtrahend
    //---------------------------------------------------
    wire [7:0] compB = ~B; // bitwise invert

    //---------------------------------------------------
    // 2) Adder-1 pass (nibble by nibble) to get partial sum
    //---------------------------------------------------
    // We'll do LSB nibble first, then MSB nibble, passing the carry along.

    // --- LSB nibble (bits [3:0]) ---
    wire [3:0] sum_lsb;
    wire       carry_lsb;
    bcd_adder_4bit adder1_lsb (
        .A(A[3:0]),
        .B(compB[3:0]),
        .cin(1'b1),   // +1 as per "1's complement plus 1"
        .sum(sum_lsb),
        .cout(carry_lsb)
    );

    // --- MSB nibble (bits [7:4]) ---
    wire [3:0] sum_msb;
    wire       carry_msb;
    bcd_adder_4bit adder1_msb (
        .A(A[7:4]),
        .B(compB[7:4]),
        .cin(carry_lsb),  // pass the nibble carry from LSB
        .sum(sum_msb),
        .cout(carry_msb)
    );

    // Put them together => partial sum from Adder-1
    // We'll interpret carry_msb as the final EAC
    wire [7:0] sum_Adder1 = { sum_msb, sum_lsb };

    // EAC = 1 => A >= B => result is positive
    // EAC = 0 => A <  B => result is negative
    assign EAC = carry_msb;

    // For debug/troubleshooting
    assign debug_Adder1 = sum_Adder1;

    //---------------------------------------------------
    // 3) Adder-2 pass (the table logic)
    //---------------------------------------------------
    // We'll do nibble by nibble again. The table says:
    //   If carry_of_nibble=1 AND EAC=1 => "Transfer real result" + "add 0000"
    //   If carry_of_nibble=0 AND EAC=1 => "Transfer real result" + "add 1010"
    //   If carry_of_nibble=1 AND EAC=0 => "Transfer 1's complement result" + "add 1010"
    //   If carry_of_nibble=0 AND EAC=0 => "Transfer 1's complement result" + "add 0000"
    // We'll define small logic to pick the "transfer real or 1's complement" 
    // and pick "add 1010 or add 0000."

    // We'll do LSB nibble second pass
    wire [3:0] final_lsb;
    wire       carry2_lsb;

    second_pass_logic nibble0_pass2 (
        .group_in  (sum_lsb),
        .carry_in  (carry_lsb),
        .EAC       (EAC),
        .group_out (final_lsb),
        .cout      (carry2_lsb)
    );

    // We'll do MSB nibble second pass
    wire [3:0] final_msb;
    wire       carry2_msb;

    second_pass_logic nibble1_pass2 (
        .group_in  (sum_msb),
        .carry_in  (carry2_lsb), // note: or pass carry_msb? 
        .EAC       (EAC),
        .group_out (final_msb),
        .cout      (carry2_msb)
    );

    // Ignore final carry out per your example
    assign DIFF_BCD = { final_msb, final_lsb };	   

endmodule

//---------------------------------------------------
// second_pass_logic
// Implements the table for a single nibble in Adder-2.
//
// "group_in" is the 4-bit partial sum from Adder-1 nibble.
// "carry_in" is the carry out from Adder-1 nibble.
//
// The table says:
//
//  carry_in | EAC=1 => real result  + (carry_in? 0000 : 1010)
//           | EAC=0 => comp result + (carry_in? 1010 : 0000)
//
// "real result" = group_in
// "comp result" = 1's complement of group_in
//
// Then we do an adder_4bit with either 0000 or 1010 as needed.
// 
//---------------------------------------------------
module second_pass_logic (
    input  wire [3:0] group_in,
    input  wire       carry_in,
    input  wire       EAC,
    output wire [3:0] group_out,
    output wire       cout
);
    // Step 1: pick "real result" or "1's complement"
    // If EAC=1 => "transfer real result"
    //    EAC=0 => "transfer 1's complement"
    wire [3:0] xfer_val = (EAC == 1'b1) ? group_in : (~group_in);

    // Step 2: pick "0000" or "1010" (decimal 10) depending on EAC and carry_in
    // The table:
    //   carry_in=1, EAC=1 => add 0000
    //   carry_in=0, EAC=1 => add 1010
    //   carry_in=1, EAC=0 => add 1010
    //   carry_in=0, EAC=0 => add 0000
    wire add_10 = ((EAC == 1'b1) && (carry_in == 1'b0)) ||
                  ((EAC == 1'b0) && (carry_in == 1'b1));

    wire [3:0] add_nibble = add_10 ? 4'b1010 : 4'b0000;

    // Step 3: add them with a 4-bit adder
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
    assign cout      = c_out; // pass the carry forward if you want
endmodule


//---------------------------------------------------
// bcd_adder_4bit
// A simple 4-bit binary adder used in the steps above.
// You could also rename this to something like "ripple_adder_4bit" 
// if you have a standard ripple adder.
//
// Just be sure each nibble add is purely binary here, 
// the BCD rules are handled by whether we add 1010 or 0000, etc.
//
// This example is a minimal ripple adder of 4 bits.
//---------------------------------------------------
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
