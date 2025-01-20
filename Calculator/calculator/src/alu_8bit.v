module alu_8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire       selAdd,
    input  wire       selSub,
    input  wire       selMul,
    input  wire       selDiv,

    output wire [15:0] result,
    output wire        status
);

    
    wire [7:0] bcd_sum;
    wire       bcd_carry;
    bcd_adder_8bit add_inst (
        .A(a),
        .B(b),
        .SUM_BCD(bcd_sum),
        .CARRY_OUT(bcd_carry)
    );
    wire [15:0] result_add  = {8'h00, bcd_sum};
    wire        status_add  = bcd_carry;

   
    wire [7:0] bcd_diff;
    wire       bcd_borrow;
    bcd_subtractor_8bit_eac sub_inst (
        .A(a),
        .B(b),
        .DIFF_BCD(bcd_diff),
        .EAC(bcd_borrow)
    );
    wire [15:0] result_sub  = {8'h00, bcd_diff};
    wire        status_sub  = bcd_borrow; // or invert if you want the opposite

   
    wire [15:0] product_mul;
    mul_8bit_logic mul_inst (
        .A(a),
        .B(b),
        .product(product_mul)
    );
    wire overflow_mul = (product_mul[15:8] != 8'h00);
    wire [15:0] result_mul  = product_mul;
    wire        status_mul  = overflow_mul;

    
    wire div_by_zero = (b == 8'h00);

    wire [7:0] quotient_div;
    wire [7:0] remainder_div;
    div_8bit_logic div_inst (
        .A(a),
        .B(b),
        .Q(quotient_div),
        .R(remainder_div)
    );
    wire [15:0] result_div = div_by_zero ? 16'hFFFF :
                              { remainder_div, quotient_div };
    wire        status_div = div_by_zero ? 1'b1 : 1'b0;

   

    wire [15:0] mux_result = (selAdd ? result_add  :
                              selSub ? result_sub  :
                              selMul ? result_mul  :
                                       result_div );

    wire        mux_status = (selAdd ? status_add  :
                              selSub ? status_sub  :
                              selMul ? status_mul  :
                                       status_div );

    
    assign result = mux_result;
    assign status = mux_status;

endmodule
