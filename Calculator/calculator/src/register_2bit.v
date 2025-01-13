// File: register_2bit.v
module register_2bit (
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [1:0] d,
    output reg  [1:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 2'b00;
        end else if (load) begin
            q <= d;
        end
    end
endmodule
