module register_8bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [7:0] d,
    output reg  [7:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 8'b0000_0000;
        end else if (load) begin
            q <= d;
        end
    end
endmodule
