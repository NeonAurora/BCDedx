// File: tb_top_2bit_alu.v
`timescale 1ns/1ps

module tb_top_2bit_alu;

    // Testbench signals
    reg        clk;
    reg        rst;
    reg  [1:0] inA;
    reg  [1:0] inB;
    reg        btnLoadA;
    reg        btnLoadB;
    reg        op;   // 0=Add, 1=Sub
    wire [2:0] led_out;
    wire       carry_borrow;

    // Instantiate top-level
    top_2bit_alu DUT (
        .clk          (clk),
        .rst          (rst),
        .inA          (inA),
        .inB          (inB),
        .btnLoadA     (btnLoadA),
        .btnLoadB     (btnLoadB),
        .op           (op),
        .led_out      (led_out),
        .carry_borrow (carry_borrow)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end

    // Test sequence
    initial begin
        // Initialize signals
        rst       = 1;
        btnLoadA  = 0;
        btnLoadB  = 0;
        op        = 0;   // default to Add
        inA       = 2'b00;
        inB       = 2'b00;
        #20;

        // Release reset
        rst = 0;
        #10;

        // ---------------------------
        // 1) Test ADD
        // ---------------------------
        // Load A = 2 (binary 10)
        inA = 2'b10;
        btnLoadA = 1;
        #10 btnLoadA = 0;  // latch A=2

        // Load B = 3 (binary 11)
        inB = 2'b11;
        btnLoadB = 1;
        #10 btnLoadB = 0;  // latch B=3

        // op=0 => Add
        op = 1;
        #10;
        
        // Wait a bit, check result
        #20;
        $display("ADD: A=%0d, B=%0d, led_out=%b (decimal %0d), carry_borrow=%b",
                 inA, inB, led_out, led_out, carry_borrow);

        // ---------------------------
        // 2) Test SUB
        // ---------------------------
        // Load A = 1 (binary 01)
        inA = 2'b01;
        btnLoadA = 1;
        #10 btnLoadA = 0;  // latch A=1

        // Load B = 2 (binary 10)
        inB = 2'b10;
        btnLoadB = 1;
        #10 btnLoadB = 0;  // latch B=2

        // op=1 => Sub
        op = 1;
        #10;
        
        // Wait a bit, check result
        #20;
        $display("SUB: A=%0d, B=%0d, led_out=%b (2's complement), carry_borrow=%b",
                 inA, inB, led_out, carry_borrow);

        // End simulation
        $stop;
    end
endmodule
