module BCD_Calculator (
    input clk,        // Clock signal
    input rst,        // Reset signal
    input start,      // Start signal
    input [3:0] A_in, // Input A
    input [3:0] B_in, // Input B
    output [3:0] Result, // Result of addition
    output Carry       // Carry output
);
    wire LoadA, LoadB, Add;
    wire [3:0] A, B;
    
    // Instantiate control circuit
    Control_Circuit control (
        .clk(clk),
        .rst(rst),
        .start(start),
        .LoadA(LoadA),
        .LoadB(LoadB),
        .Add(Add)
    );
    
    // Instantiate registers
    BCD_Register regA (
        .clk(clk),
        .rst(rst),
        .DataIn(A_in),
        .Load(LoadA),
        .DataOut(A)
    );
    
    BCD_Register regB (
        .clk(clk),
        .rst(rst),
        .DataIn(B_in),
        .Load(LoadB),
        .DataOut(B)
    );
    
    // Instantiate ALU
    BCD_ALU alu (
        .A(A),
        .B(B),
        .Add(Add),
        .Result(Result),
        .Carry(Carry)
    );
endmodule
