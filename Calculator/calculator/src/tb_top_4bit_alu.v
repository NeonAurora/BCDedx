// File: tb_top_4bit_alu.v
`timescale 1ns/1ps

module tb_top_4bit_alu;
    // Testbench signals
    reg        clk;
    reg        rst;
    reg  [3:0] inA;
    reg  [3:0] inB;
    reg        btnLoadA;
    reg        btnLoadB;
    reg  [1:0] op;        // 00=Add, 01=Sub, 10=Mul, 11=Div
    wire [7:0] led_out;   // 8-bit result
    wire       flag_out;  // status bit

    // Instantiate the top-level
    top_4bit_alu DUT (
        .clk      (clk),
        .rst      (rst),
        .inA      (inA),
        .inB      (inB),
        .btnLoadA (btnLoadA),
        .btnLoadB (btnLoadB),
        .op       (op),
        .led_out  (led_out),
        .flag_out (flag_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Debug wires to see internal register outputs
    wire [3:0] regA_out_tb = DUT.regA_out;
    wire [3:0] regB_out_tb = DUT.regB_out;

    // Test sequence
    initial begin
        // Initial states
        rst       = 1;
        btnLoadA  = 0;
        btnLoadB  = 0;
        op        = 2'b00;
        inA       = 4'b0000;
        inB       = 4'b0000;
        #20;

        // Release reset
        rst = 0;
        #10;

        // -----------------------------------
        // 1) ADD:  A=9 (1001), B=6 (0110)
        //          sum = 15 (01111), carried in 5 bits
        //          store that in bottom 5 bits => 01111 => 0x0F
        // -----------------------------------
        inA = 4'b1001;  // 9
        btnLoadA = 1;  #10 btnLoadA = 0;
        inB = 4'b0110;  // 6
        btnLoadB = 1;  #10 btnLoadB = 0;

        op = 2'b00;     // Add
        #20;
        $display("[ADD] A=%d, B=%d => led_out=%b (%0d), flag=%b (carry)",
                 regA_out_tb, regB_out_tb, led_out, led_out, flag_out);

        // -----------------------------------
        // 2) SUB: A=2 (0010), B=5 (0101)
        //    => 2 - 5 = -3 (in 2's complement = 1101 if we store in lower 4 bits)
        // -----------------------------------
        inA = 4'b0010;  // 2
        btnLoadA = 1;  #10 btnLoadA = 0;
        inB = 4'b0101;  // 5
        btnLoadB = 1;  #10 btnLoadB = 0;

        op = 2'b01;     // Sub
        #20;
        $display("[SUB] A=%d, B=%d => led_out=%b, flag=%b (borrow)",
                 regA_out_tb, regB_out_tb, led_out, flag_out);

        // -----------------------------------
        // 3) MUL: A=7 (0111), B=3 (0011)
        //    => 21 = decimal, 21 = 10101 (5 bits)
        //    => In 8 bits => 00010101 = 0x15
        // -----------------------------------
        inA = 4'b0111;  // 7
        btnLoadA = 1;  #10 btnLoadA = 0;
        inB = 4'b0011;  // 3
        btnLoadB = 1;  #10 btnLoadB = 0;

        op = 2'b10;     // Mul
        #20;
        $display("[MUL] A=%d, B=%d => led_out=%b (%0d), flag=%b (overflow?)",
                 regA_out_tb, regB_out_tb, led_out, led_out, flag_out);

        // -----------------------------------
        // 4) DIV: A=13 (1101), B=3 (0011)
        //    => quotient=4 (0100), remainder=1 (0001)
        //    => result[7:4] = remainder(0001), result[3:0] = quotient(0100)
        //    => result= 00010100 (0x14)
        // -----------------------------------
        inA = 4'b1101;  // 13
        btnLoadA = 1;  #10 btnLoadA = 0;
        inB = 4'b0011;  // 3
        btnLoadB = 1;  #10 btnLoadB = 0;

        op = 2'b11;     // Div
        #20;
        $display("[DIV] A=%d, B=%d => led_out=%b, remainder=%b, quotient=%b, flag=%b (div0?)",
                 regA_out_tb, regB_out_tb, 
                 led_out, led_out[7:4], led_out[3:0], flag_out);

        // -----------------------------------
        // 4b) DIV by zero test
        // -----------------------------------
        inA = 4'b1010; // 10
        btnLoadA = 1;  #10 btnLoadA = 0;
        inB = 4'b0000; // 0
        btnLoadB = 1;  #10 btnLoadB = 0;

        op = 2'b11;     // Div
        #20;
        $display("[DIV-ZERO] A=%d, B=%d => led_out=%b, flag=%b (div0)",
                 regA_out_tb, regB_out_tb, led_out, flag_out);

        $stop;
    end
endmodule
