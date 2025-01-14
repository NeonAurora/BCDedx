module BCD_ALU (
    input [3:0] A,  // 2-bit BCD input (4 bits to represent 0-9 in BCD)
    input [3:0] B,  // 2-bit BCD input
    input Add,      // Control signal to perform addition
    output reg [3:0] Result, // Result of BCD addition
    output reg Carry          // Carry output for BCD addition
);
    always @(*) begin
        if (Add) begin
            {Carry, Result} = A + B; // Perform binary addition
            if (Result > 4'd9) begin
                Result = Result + 4'd6; // BCD correction
                Carry = 1; // Set carry if the result exceeds BCD range
            end else begin
                Carry = 0; // No carry
            end
        end else begin
            Result = 4'd0;
            Carry = 0;
        end
    end
endmodule
