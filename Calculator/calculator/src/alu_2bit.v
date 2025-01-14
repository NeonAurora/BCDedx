// File: alu_2bit.v
module alu_2bit (
    input  wire [1:0] a,
    input  wire [1:0] b,
    input  wire [1:0] op,     // 00=Add, 01=Sub, 10=Mul, 11=Div
    output reg  [3:0] result, // 4-bit result
    output reg        status  // carry/borrow/overflow/div0
);

    // ----- Add -----
    wire [3:0] sum_add = a + b;       // up to 4 bits
    wire       carry   = sum_add[3];  // top bit is carry

    // ----- Sub -----
    // For a 2-bit minus 2-bit, we store in 4 bits (2’s complement if negative).
    // Borrow = 1 if b > a in unsigned sense.
    wire [3:0] diff_sub = {{2{a[1]}}, a} - {{2{b[1]}}, b};
    wire       borrow   = (b > a) ? 1'b1 : 1'b0;

    // ----- Mul -----
    // 2-bit x 2-bit => up to 4 bits
    wire [3:0] prod_mul = a * b;
    // If it exceeds 3 bits (i.e. >= 8), we might consider that an "overflow".
    wire       overflow = (prod_mul[3] == 1'b1) ? 1'b1 : 1'b0;

    // ----- Div -----
    // 2-bit ÷ 2-bit => up to 2-bit quotient, 2-bit remainder
    // Check for b == 0
    wire       div_by_zero = (b == 2'b00);
    wire [1:0] quotient    = (div_by_zero) ? 2'b00 : (a / b);
    wire [1:0] remainder   = (div_by_zero) ? 2'b00 : (a % b);

    always @(*) begin
        case (op)
            2'b00: begin  // ADD
                result = sum_add;    // 4-bit sum
                status = carry;      // carry out
            end
            2'b01: begin  // SUB
                result = diff_sub;   // 4-bit difference
                status = borrow;     // borrow out
            end
            2'b10: begin  // MUL
                result = prod_mul;   // 4-bit product
                status = overflow;   // overflow bit
            end
            2'b11: begin  // DIV
                if (div_by_zero) begin
                    // Indicate error if dividing by zero
                    result = 4'b1111;
                    status = 1'b1;  // set an error flag
                end else begin
                    // remainder in top bits, quotient in bottom bits
                    result = { remainder, quotient };
                    status = 1'b0;  // no error
                end
            end
            default: begin
                // Shouldn’t happen since op is only 2 bits
                result = 4'b0000;
                status = 1'b0;
            end
        endcase
    end

endmodule
