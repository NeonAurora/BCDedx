module div_stage (
    input  wire [8:0] inRem,    // 9-bit remainder from previous stage
    input  wire       topBit,   // next bit from A
    input  wire [7:0] divisor,  // B
    output wire [8:0] outRem,   // new remainder
    output wire       qBit      // 1 => remainder >= divisor
);
    // 1) Shift left by 1: [8:0] => <<1 => [8:1], new LSB= topBit
    wire [8:0] shifted = {inRem[7:0], topBit};

    // 2) Subtract divisor from shifted => 9-bit sub
    // We treat 'divisor' as an 9-bit value with top bit=0
    wire [8:0] divisor_9 = {1'b0, divisor};

    wire [8:0] diff;
    wire       borrow;

    ripple_sub_9bit sub9 (
        .x   (shifted),
        .y   (divisor_9),
        .diff(diff),
        .borrow(borrow)
    );

    // If no borrow => shifted >= divisor => remainder= diff, qBit=1
    // If borrow => remainder= shifted, qBit=0
    assign qBit   = ~borrow;
    assign outRem = borrow ? shifted : diff;
endmodule
