// File: alu_4bit.v
module alu_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,       // 00=Add, 01=Sub, 10=Mul, 11=Div
    output reg  [7:0] result,   // 8-bit result for all operations
    output reg        status    // carry/borrow/overflow/div0
);

    // ------ ADD ------
    // a + b => up to 5 bits, but we’ll store in 8 bits for consistency
    wire [3:0] sum_add;
    wire       carry;
	
	bcd_adder_4bit bcd_add_unit (
		.a(a),
		.b(b),
		.sum_bcd(sum_add),
		.carry_out(carry)
	);

    // ------ SUB ------
    // a - b => up to 5 bits in 2’s complement. We'll keep it in 8 bits.
    // Borrow set if b>a in unsigned sense.
    wire signed [4:0] diff_sub = a - b;  
    wire              borrow   = (b > a) ? 1'b1 : 1'b0;

    // ------ MUL ------
    // 4-bit * 4-bit => up to 8 bits
    wire [7:0] prod_mul = a * b;
    // Overflow for 4x4 can happen if product > 15 (0xF), i.e. if high nibble != 0. 
    wire       overflow = (prod_mul[7:4] != 4'b0000);

    // ------ DIV ------
    // 4-bit ÷ 4-bit => up to 4-bit quotient, 4-bit remainder
    // If b==0 => divide-by-zero error => set result=0xFF or something
    wire       div_by_zero = (b == 4'b0000);
    wire [3:0] quotient    = (div_by_zero) ? 4'b0000 : (a / b);
    wire [3:0] remainder   = (div_by_zero) ? 4'b0000 : (a % b);

    always @(*) begin
        case (op)
            2'b00: begin  // ADD
                // Lower 5 bits is sum, but store in 8. 
                // sum_add is 5 bits => [4]=carry, [3:0]=actual sum
                result = { 3'b000, sum_add }; 
                status = carry;  // carry out
            end

            2'b01: begin  // SUB
                // Store difference in lower bits, sign-extended? For now,
                // just keep everything in lower 5 bits, and upper bits = sign extension
                // or zero. Let's do sign extension:
                if (diff_sub[4] == 1'b1) begin
                    // Negative in 2's complement
                    result = { 3'b111, diff_sub[4:0] };
                end else begin
                    result = { 3'b000, diff_sub[4:0] };
                end
                status = borrow; // borrow out
            end

            2'b10: begin  // MUL
                // Full 8 bits of product
                result = prod_mul; 
                status = overflow; // if product > 15 decimal
            end

            2'b11: begin  // DIV
                if (div_by_zero) begin
                    result = 8'hFF;  // all ones => error
                    status = 1'b1;   // div-by-zero error
                end else begin
                    // Pack remainder in high nibble, quotient in low nibble
                    result = { remainder, quotient };
                    status = 1'b0;   // no error
                end
            end

            default: begin
                result = 8'h00;
                status = 1'b0;
            end
        endcase
    end

endmodule	