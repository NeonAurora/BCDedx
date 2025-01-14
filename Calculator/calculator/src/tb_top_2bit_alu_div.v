// File: tb_top_2bit_alu_div.v
`timescale 1ns/1ps

module tb_top_2bit_alu_div;

    // Testbench signals
    reg        clk;
    reg        rst;
    reg  [1:0] inA;
    reg  [1:0] inB;
    reg        btnLoadA;
    reg        btnLoadB;
    reg  [1:0] op;
    wire [3:0] led_out;
    wire       flag_out; // carry/borrow/overflow/div0

    // Instantiate top-level
    top_2bit_alu_div DUT (
        .clk       (clk),
        .rst       (rst),
        .inA       (inA),
        .inB       (inB),
        .btnLoadA  (btnLoadA),
        .btnLoadB  (btnLoadB),
        .op        (op),
        .led_out   (led_out),
        .flag_out  (flag_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Optional direct debugging signals
    wire [1:0] regA_out_tb = DUT.regA_out;
    wire [1:0] regB_out_tb = DUT.regB_out;

    // Test sequence
    initial begin
        // Initialize
        rst      = 1;
        btnLoadA = 0;
        btnLoadB = 0;
        op       = 2'b00;
        inA      = 2'b00;
        inB      = 2'b00;
        #20;

        // Release reset
        rst = 0;
        #10;

        // ==========================================
        // 1) ADD: A=3, B=1 => result=4 (0100), carry=0
        // ==========================================
        inA = 2'b11;  // 3
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 2'b01;  // 1
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b00;   // Add
        #20;
        $display("[ADD] A=%0d, B=%0d => Out=%b (%0d), flag=%b",
                 regA_out_tb, regB_out_tb, led_out, led_out, flag_out);

        // ==========================================
        // 2) SUB: A=1, B=3 => result=-2 in 4-bit 2's complement (1110), borrow=1
        // ==========================================
        inA = 2'b01;  // 1
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 2'b11;  // 3
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b01;   // Sub
        #20;
        $display("[SUB] A=%0d, B=%0d => Out=%b (2's comp), flag=%b (borrow)",
                 regA_out_tb, regB_out_tb, led_out, flag_out);

        // ==========================================
        // 3) MUL: A=2, B=3 => result=6 (0110), overflow=0
        // ==========================================
        inA = 2'b10;  // 2
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 2'b11;  // 3
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b10;   // Mul
        #20;
        $display("[MUL] A=%0d, B=%0d => Out=%b (%0d), flag=%b (overflow)",
                 regA_out_tb, regB_out_tb, led_out, led_out, flag_out);

        // ==========================================
        // 4) DIV: A=3, B=2 => quotient=1 (01), remainder=1 (01)
        //     => result = remainder_in_top_bits + quotient_in_bottom_bits
        //     => result = 01_01 = 0101
        // ==========================================
        inA = 2'b11;  // 3
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 2'b10;  // 2
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b11;   // Div
        #20;
        $display("[DIV] A=%0d, B=%0d => Out=%b => (rem=%0d, quo=%0d), flag=%b (div0?)",
                 regA_out_tb, regB_out_tb, led_out, led_out[3:2], led_out[1:0], flag_out);

        // ==========================================
        // 4b) DIV by zero test
        // ==========================================
        inA = 2'b10;  // 2
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 2'b00;  // 0
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b11;   // Div
        #20;
        $display("[DIV-ZERO] A=%0d, B=%0d => Out=%b, flag=%b (div0)",
                 regA_out_tb, regB_out_tb, led_out, flag_out);

        $stop;
    end
endmodule
