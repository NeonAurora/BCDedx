module Control_Circuit (
    input clk,       // Clock signal
    input rst,       // Reset signal
    input start,     // Start signal
    output reg LoadA,// Load enable for register A
    output reg LoadB,// Load enable for register B
    output reg Add   // Control signal for addition operation
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            LoadA <= 0;
            LoadB <= 0;
            Add <= 0;
        end else if (start) begin
            LoadA <= 1; // Load input to A
            LoadB <= 1; // Load input to B
            Add <= 1;   // Enable addition
        end else begin
            LoadA <= 0;
            LoadB <= 0;
            Add <= 0;
        end
    end
endmodule
