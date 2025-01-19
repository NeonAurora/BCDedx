// File: ripple_sub_9bit.v
// 9-bit subtract: diff = x - y
// We'll do x + (~y) + 1 => if carry=0 => borrow=1
// We'll build it from two 4-bit blocks + 1-bit block 

module ripple_sub_9bit (
    input  wire [8:0] x,
    input  wire [8:0] y,
    output wire [8:0] diff,
    output wire       borrow
);
    wire [8:0] y_invert = ~y; 
    wire [8:0] sum;
    wire       cout;

    // We'll do a 9-bit ripple add = x + y_invert + 1
    // The final carry=1 => means x>=y => no borrow
    // The final carry=0 => x<y => borrow=1

    // We'll build a little chain:
    wire [3:0] sum_lo;
    wire       c_lo;
    ripple_adder_4bit ra_lo(
        .a(x[3:0]),
        .b(y_invert[3:0]),
        .cin(1'b1),  // +1
        .sum(sum_lo),
        .cout(c_lo)
    );

    wire [3:0] sum_mid;
    wire       c_mid;
    ripple_adder_4bit ra_mid(
        .a(x[7:4]),
        .b(y_invert[7:4]),
        .cin(c_lo),
        .sum(sum_mid),
        .cout(c_mid)
    );

    // Now the 9th bit
    wire sum_bit8;
    wire cout_bit8;
    full_adder fa_8(
        .a(x[8]),
        .b(y_invert[8]),
        .cin(c_mid),
        .sum(sum_bit8),
        .cout(cout_bit8)
    );

    assign sum = {sum_bit8, sum_mid, sum_lo};
    // if cout_bit8=1 => no borrow => x>=y
    // if cout_bit8=0 => borrow => x<y
    assign borrow = ~cout_bit8;

    assign diff   = sum;

endmodule
