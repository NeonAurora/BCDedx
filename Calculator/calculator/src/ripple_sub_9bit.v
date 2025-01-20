 

module ripple_sub_9bit (
    input  wire [8:0] x,
    input  wire [8:0] y,
    output wire [8:0] diff,
    output wire       borrow
);
    wire [8:0] y_invert = ~y; 
    wire [8:0] sum;
    wire       cout;
			
    wire [3:0] sum_lo;
    wire       c_lo;
    ripple_adder_4bit ra_lo(
        .a(x[3:0]),
        .b(y_invert[3:0]),
        .cin(1'b1),  
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
    assign borrow = ~cout_bit8;

    assign diff   = sum;

endmodule
