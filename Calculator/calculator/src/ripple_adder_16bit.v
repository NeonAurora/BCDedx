// File: ripple_adder_16bit.v
// Builds a 16-bit adder from four 4-bit ripple adders.	

module ripple_adder_16bit (
    input  wire [15:0] a,
    input  wire [15:0] b,
    input  wire        cin,
    output wire [15:0] sum,
    output wire        cout
);
    wire c1, c2, c3;

    // lower 4 bits
    ripple_adder_4bit ra0 (
        .a(a[3:0]),
        .b(b[3:0]),
        .cin(cin),
        .sum(sum[3:0]),
        .cout(c1)
    );

    // next 4 bits
    ripple_adder_4bit ra1 (
        .a(a[7:4]),
        .b(b[7:4]),
        .cin(c1),
        .sum(sum[7:4]),
        .cout(c2)
    );

    // next 4 bits
    ripple_adder_4bit ra2 (
        .a(a[11:8]),
        .b(b[11:8]),
        .cin(c2),
        .sum(sum[11:8]),
        .cout(c3)
    );

    // top 4 bits
    ripple_adder_4bit ra3 (
        .a(a[15:12]),
        .b(b[15:12]),
        .cin(c3),
        .sum(sum[15:12]),
        .cout(cout)
    );
endmodule
