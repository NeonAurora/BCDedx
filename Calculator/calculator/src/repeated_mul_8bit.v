module repeated_mul_8bit(
    input  wire clk,
    input  wire rst,
    input  wire start,
    input  wire [7:0] A,
    input  wire [7:0] B,
    output reg  [15:0] product,
    output reg  done
);
    // We'll do a simple approach: 
    // product = 0 initially, then while B>0 => product += A, B--
    // This is a multi-cycle approach.

    reg [7:0]  count;
    reg [15:0] accum;
    reg        busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product <= 16'h0000;
            done    <= 1'b0;
            count   <= 8'h00;
            accum   <= 16'h0000;
            busy    <= 1'b0;
        end else begin
            if (start) begin
                // init
                accum <= 16'h0000;
                count <= B;
                done  <= 1'b0;
                busy  <= 1'b1;
            end else if (busy) begin
                if (count != 0) begin
                    accum <= accum + A;
                    count <= count - 1;
                end else begin
                    // done
                    product <= accum;
                    done    <= 1'b1;
                    busy    <= 1'b0;
                end
            end
        end
    end
endmodule
