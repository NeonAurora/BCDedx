// File: adder_2bit.v
module adder_2bit (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [2:0] sum
);
    assign sum = a + b; 
endmodule
