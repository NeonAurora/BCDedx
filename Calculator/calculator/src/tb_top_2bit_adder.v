// File: tb_top_2bit_adder.v
`timescale 1ns/1ps

module tb_top_2bit_adder;

    // Testbench signals
    reg        clk;
    reg        rst;
    reg  [1:0] inA;
    reg  [1:0] inB;
    reg        btnLoadA;
    reg        btnLoadB;
    wire [2:0] led_out;

    // Instantiate top module
    top_2bit_adder DUT (
        .clk      (clk),
        .rst      (rst),
        .inA      (inA),
        .inB      (inB),
        .btnLoadA (btnLoadA),
        .btnLoadB (btnLoadB),
        .led_out  (led_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period -> 100MHz
    end

    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        inA = 2'b00;
        inB = 2'b00;
        btnLoadA = 0;
        btnLoadB = 0;
        #20;
        
        // Release reset
        rst = 0;
        #10;
        
        // Load inA = 2 (binary 10)
        inA = 2'b10;
        btnLoadA = 1;
        #10;
        btnLoadA = 0;

        // Load inB = 3 (binary 11)
        inB = 2'b11;
        btnLoadB = 1;
        #10;
        btnLoadB = 0;

        // Wait a few clock cycles
        #50;

        // Check sum = 010 + 011 = 101 (decimal 5)
        $display("SUM = %b (decimal %0d)", led_out, led_out);

        // End simulation
        $stop;
    end
endmodule
