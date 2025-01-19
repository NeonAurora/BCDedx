// File: alu_8bit.v												   

module alu_8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [1:0] op,       // 00=Add, 01=Sub, 10=Mul, 11=Div
    output reg  [15:0] result,  // 16-bit result to hold largest product
    output reg         status   // carry/borrow/overflow/div0
);

    //------------------------------------------------
    // BCD ADD (op=00)
    //------------------------------------------------
    wire [7:0] bcd_sum;
    wire       bcd_carry;  // 1 if sum >= 100 decimal
    bcd_adder_8bit bcd_add_inst (
        .A(a),
        .B(b),
        .SUM_BCD(bcd_sum),
        .CARRY_OUT(bcd_carry)
    );

    //------------------------------------------------
    // BCD SUB (op=01)
    //------------------------------------------------
    wire [7:0] bcd_diff;
    wire       bcd_borrow; // 1 if A < B
    bcd_subtractor_8bit_eac bcd_sub_inst (
        .A(a),
        .B(b),
        .DIFF_BCD(bcd_diff),
        .EAC(bcd_borrow)
    );

    //------------------------------------------------
    // MUL (binary for now) (op=10)
    // 8-bit x 8-bit => up to 16 bits
    //------------------------------------------------
    wire [15:0] prod_mul = a * b; 
    // Overflow if upper byte != 0
    wire        overflow_mul = (prod_mul[15:8] != 8'h00);

    //------------------------------------------------
    // DIV (binary for now) (op=11)
    // Remainder in high byte, quotient in low byte
    //------------------------------------------------
    wire       div_by_zero = (b == 8'h00);
    wire [7:0] quotient    = div_by_zero ? 8'h00 : (a / b);
    wire [7:0] remainder   = div_by_zero ? 8'h00 : (a % b);

    always @(*) begin
        case (op)
            // ------------------ BCD ADD ------------------
            2'b00: begin
                // bcd_sum is 8 bits of two-digit BCD,
                // if sum >= 100 decimal => bcd_carry=1
                // We'll place the 8-bit BCD result in the low byte of 'result'
                // The top 8 bits = 0
                result = {8'h00, bcd_sum}; 
                // status = bcd_carry
                status = bcd_carry;
            end

            // ------------------ BCD SUB ------------------
            2'b01: begin
                // bcd_diff is 8 bits of two-digit BCD
                // if A < B => bcd_borrow=1
                result = {8'h00, bcd_diff};
                status = bcd_borrow;
            end

            // ------------------ BINARY MUL ------------------
            2'b10: begin
                // 16-bit product
                result = prod_mul;
                // overflow if product > 255 decimal
                status = overflow_mul;
            end

            // ------------------ BINARY DIV ------------------
            2'b11: begin
                if (div_by_zero) begin
                    // error code
                    result = 16'hFFFF;
                    status = 1'b1;
                end else begin
                    // remainder in high byte, quotient in low byte
                    result = { remainder, quotient };
                    status = 1'b0;
                end
            end

            // ------------------ Default ------------------
            default: begin
                result = 16'h0000;
                status = 1'b0;
            end
        endcase
    end

endmodule
