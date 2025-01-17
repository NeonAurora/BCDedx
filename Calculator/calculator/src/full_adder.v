// File: full_adder.v
module full_adder (
    input  wire a,    // 1-bit input
    input  wire b,    // 1-bit input
    input  wire cin,  // carry in
    output wire sum,  // sum bit
    output wire cout  // carry out
);
    // sum = a ^ b ^ cin
    assign sum  = a ^ b ^ cin;
    // carry out = (a & b) | (b & cin) | (a & cin)
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
														  	