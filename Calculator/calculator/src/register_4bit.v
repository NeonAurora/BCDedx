// File: register_4bit.v
module register_4bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 4'b0000;
        end else if (load) begin
            q <= d;
        end
    end
endmodule
