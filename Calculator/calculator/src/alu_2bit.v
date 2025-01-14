// File: alu_2bit.v
module alu_2bit (
    input  wire [1:0] a,
    input  wire [1:0] b,
    input  wire [1:0] op,   // 00=Add, 01=Sub, 10=Mul
    output reg  [3:0] result,
    output reg        status  // could be carry/borrow/overflow
);

    // ----- Add -----
    // 2-bit + 2-bit => up to 3 bits, but we'll store in 4 bits
    wire [3:0] sum_add = a + b;
    wire       carry   = sum_add[3];  // MSB is carry out for addition

    // ----- Sub -----
    // 2-bit - 2-bit => can be negative in 2's complement
    // We'll keep 4 bits for uniformity. If negative, MSB bits show sign in 2's complement.
    // For unsigned borrow detection: if b > a, set borrow = 1
    wire [3:0] diff_sub = {{2{a[1]}}, a} - {{2{b[1]}}, b};  
    // Another simpler approach could be: diff_sub = a - b (extended to 4 bits).
    wire       borrow   = (b > a) ? 1'b1 : 1'b0;

    // ----- Mul -----
    // 2-bit x 2-bit => up to 4 bits
    wire [3:0] prod_mul = a * b;
    // Overflow if product exceeds 3 bits. But since we’re storing in 4 bits, 
    // the only "overflow" would be if the product is bigger than 4 bits, 
    // but 2x2 always fits in 4 bits. We could set a simpler status bit if the 
    // product is > 3 decimal, or something else. 
    // For demonstration, let's say "overflow = 1 if product > 3 bits."
    wire       overflow = (|prod_mul[3:3]) ? 1'b1 : 1'b0; 
    // Actually, this just checks bit 3, but that’s enough for 2-bit multiply.

    always @(*) begin
        case (op)
            2'b00: begin  // ADD
                result = sum_add;
                status = carry; // carry out for add
            end
            2'b01: begin  // SUB
                result = diff_sub;
                status = borrow; // borrow out for sub
            end
            2'b10: begin  // MUL
                result = prod_mul;
                status = overflow; // overflow out for multiply
            end
            default: begin
                // If we wanted a 4th operation (e.g. division), we could do it here.
                // For now, let's just default to 0.
                result = 4'b0000;
                status = 1'b0;
            end
        endcase
    end
endmodule
