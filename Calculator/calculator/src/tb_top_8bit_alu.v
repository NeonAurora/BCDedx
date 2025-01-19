// File: tb_top_8bit_alu.v
`timescale 1ns/1ps

module tb_top_8bit_alu;
    // Testbench signals
    reg        clk;
    reg        rst;
    reg  [7:0] inA;
    reg  [7:0] inB;
    reg        btnLoadA;
    reg        btnLoadB;
    reg  [1:0] op;
    wire [15:0] led_out;
    wire        flag_out;

    // Instantiate top-level
    top_8bit_alu DUT (
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

    // Test sequence
    initial begin
        // Initialize
        rst       = 1;
        btnLoadA  = 0;
        btnLoadB  = 0;
        op        = 2'b00;
        inA       = 8'h00;
        inB       = 8'h00;
        #20;

        // Release reset
        rst = 0;
        #10;

        // 1) ADD: A=9, B=6
        inA = 8'd10;
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 8'd9;
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b00;  // Add
        #20;
        $display("ADD: A=%d, B=%d => led_out=%h, flag=%b", 
                 DUT.regA_out, DUT.regB_out, led_out, flag_out);

        // 2) SUB: A=2, B=5
        inA = 8'd2;
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 8'd7;
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b01;  // Sub
        #20;
        $display("SUB: A=%d, B=%d => led_out=%h, flag=%b",
                 DUT.regA_out, DUT.regB_out, led_out, flag_out);

        // 3) MUL: A=15, B=10
        inA = 8'd3;
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 8'd2;
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b10;  // Mul
        #20;
        $display("MUL: A=%d, B=%d => led_out=%h, flag=%b",
                 DUT.regA_out, DUT.regB_out, led_out, flag_out);

        // 4) DIV: A=100, B=3
        inA = 8'd15;
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 8'd3;
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b11;  // Div
        #20;
        $display("DIV: A=%d, B=%d => led_out=%h, remainder=%d, quotient=%d, flag=%b",
                 DUT.regA_out, DUT.regB_out, led_out, led_out[15:8], led_out[7:0], flag_out);

        // 4b) DIV ZERO: A=20, B=0
        inA = 8'd20;
        btnLoadA = 1; #10 btnLoadA = 0;
        inB = 8'd0;
        btnLoadB = 1; #10 btnLoadB = 0;

        op = 2'b11;  // Div
        #20;
        $display("DIV-ZERO: A=%d, B=%d => led_out=%h, flag=%b",
                 DUT.regA_out, DUT.regB_out, led_out, flag_out);

        $stop;
    end
endmodule
