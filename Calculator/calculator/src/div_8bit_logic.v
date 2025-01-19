// File: div_8bit_logic.v
//
// Pure logic-based 8-bit unsigned division using
// "shift-and-subtract" method, unrolled into 8 stages.
//
// Inputs:
//   A = dividend (8 bits)
//   B = divisor  (8 bits)
// Outputs:
//   Q = 8-bit quotient
//   R = 8-bit remainder
// 
// If B=0 => we set Q=0, R=0, or treat as a special case.  

module div_8bit_logic (
    input  wire [7:0] A,
    input  wire [7:0] B,
    output wire [7:0] Q,
    output wire [7:0] R
);
    // 1) If B=0 => quotient=0, remainder=0
    //    We'll handle that externally or internal:
    wire div_by_zero = (B == 8'h00);

    // If div_by_zero, we skip all logic below and force Q=R=0
    // Otherwise do shift-sub approach.

    // We'll do partial remainder in 9 bits for each stage.
    // Start remainder= 0, we shift in bits of A from MSB->LSB
    // Each stage:
    //   remainder = (remainder << 1) + next_bit_of_A
    //   subtract B => if remainder >= B => remainder= remainder - B, qbit=1 else qbit=0
    //
    // We store each qbit in Q from MSB to LSB.

    // Stage 0 input:
    // remainder0 = 0
    // We'll shift in A[7].
    // Then if remainder0 >= B => remainder0= remainder0 - B, Q[7]=1 else Q[7]=0

    // We'll define wires for remainder after each stage, plus Q bits.
    // remainder_i is 9 bits for safety.
    // stage0 => stage1 => ...
    
    // First define a "base" remainder for stage0 = 0
    wire [8:0] rem_base = 9'd0;

    // We'll unroll 8 stages
    wire [8:0] rem_s0, rem_s1, rem_s2, rem_s3;
    wire [8:0] rem_s4, rem_s5, rem_s6, rem_s7;
    wire       qbit7, qbit6, qbit5, qbit4;
    wire       qbit3, qbit2, qbit1, qbit0;

    // STAGE 0: shift in A[7]
    div_stage stage0 (
        .inRem   (rem_base),
        .topBit  (A[7]),   // MSB of A
        .divisor (B),
        .outRem  (rem_s0),
        .qBit    (qbit7)
    );

    // STAGE 1: shift in A[6]
    div_stage stage1 (
        .inRem   (rem_s0),
        .topBit  (A[6]),
        .divisor (B),
        .outRem  (rem_s1),
        .qBit    (qbit6)
    );

    // STAGE 2: shift in A[5]
    div_stage stage2 (
        .inRem   (rem_s1),
        .topBit  (A[5]),
        .divisor (B),
        .outRem  (rem_s2),
        .qBit    (qbit5)
    );

    // STAGE 3: shift in A[4]
    div_stage stage3 (
        .inRem   (rem_s2),
        .topBit  (A[4]),
        .divisor (B),
        .outRem  (rem_s3),
        .qBit    (qbit4)
    );

    // STAGE 4: shift in A[3]
    div_stage stage4 (
        .inRem   (rem_s3),
        .topBit  (A[3]),
        .divisor (B),
        .outRem  (rem_s4),
        .qBit    (qbit3)
    );

    // STAGE 5: shift in A[2]
    div_stage stage5 (
        .inRem   (rem_s4),
        .topBit  (A[2]),
        .divisor (B),
        .outRem  (rem_s5),
        .qBit    (qbit2)
    );

    // STAGE 6: shift in A[1]
    div_stage stage6 (
        .inRem   (rem_s5),
        .topBit  (A[1]),
        .divisor (B),
        .outRem  (rem_s6),
        .qBit    (qbit1)
    );

    // STAGE 7: shift in A[0]
    div_stage stage7 (
        .inRem   (rem_s6),
        .topBit  (A[0]),
        .divisor (B),
        .outRem  (rem_s7),
        .qBit    (qbit0)
    );

    // final remainder is rem_s7[7:0], ignoring the top bit
    // final quotient bits are qbit7..qbit0
    // BUT if B=0 => Q=0, R=0
    wire [7:0] quotient_raw   = {qbit7, qbit6, qbit5, qbit4, qbit3, qbit2, qbit1, qbit0};
    wire [7:0] remainder_raw  = rem_s7[7:0];

    assign Q = (div_by_zero) ? 8'h00 : quotient_raw;
    assign R = (div_by_zero) ? 8'h00 : remainder_raw;

endmodule
