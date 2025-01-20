// File: controller_2bit.v
module controller_2bit (
    // Existing button-based load logic
    input  wire btnLoadA,
    input  wire btnLoadB,
    output wire loadA,
    output wire loadB,

    // New opcode input (2 bits)
    input  wire [1:0] op,

    // Decoded select lines for the ALU
    output wire selAdd,  // op=00 => 1
    output wire selSub,  // op=01 => 1
    output wire selMul,  // op=10 => 1
    output wire selDiv   // op=11 => 1
);
    // 1) Pass through for load signals
    assign loadA = btnLoadA;
    assign loadB = btnLoadB;

    // 2) Decode 'op' into four separate “select” lines
    assign selAdd = (op == 2'b00);
    assign selSub = (op == 2'b01);
    assign selMul = (op == 2'b10);
    assign selDiv = (op == 2'b11);
endmodule
