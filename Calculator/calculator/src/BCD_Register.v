module BCD_Register (
    input clk,          // Clock signal
    input rst,          // Reset signal
    input [3:0] DataIn, // Input data
    input Load,         // Load enable
    output reg [3:0] DataOut // Stored data
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            DataOut <= 4'd0; // Clear register on reset
        else if (Load)
            DataOut <= DataIn; // Load data on Load signal
    end
endmodule
