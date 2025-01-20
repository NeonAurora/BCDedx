// File: div_8bit_logic.v		

module div_8bit_logic (
    input  wire [7:0] A,
    input  wire [7:0] B,
    output wire [7:0] Q,
    output wire [7:0] R
);
    
    wire div_by_zero = (B == 8'h00);	  
    wire [8:0] rem_base = 9'd0;

   
    wire [8:0] rem_s0, rem_s1, rem_s2, rem_s3;
    wire [8:0] rem_s4, rem_s5, rem_s6, rem_s7;
    wire       qbit7, qbit6, qbit5, qbit4;
    wire       qbit3, qbit2, qbit1, qbit0;

   
    div_stage stage0 (
        .inRem   (rem_base),
        .topBit  (A[7]),   
        .divisor (B),
        .outRem  (rem_s0),
        .qBit    (qbit7)
    );

   
    div_stage stage1 (
        .inRem   (rem_s0),
        .topBit  (A[6]),
        .divisor (B),
        .outRem  (rem_s1),
        .qBit    (qbit6)
    );

    
    div_stage stage2 (
        .inRem   (rem_s1),
        .topBit  (A[5]),
        .divisor (B),
        .outRem  (rem_s2),
        .qBit    (qbit5)
    );

   
    div_stage stage3 (
        .inRem   (rem_s2),
        .topBit  (A[4]),
        .divisor (B),
        .outRem  (rem_s3),
        .qBit    (qbit4)
    );

    
    div_stage stage4 (
        .inRem   (rem_s3),
        .topBit  (A[3]),
        .divisor (B),
        .outRem  (rem_s4),
        .qBit    (qbit3)
    );

   
    div_stage stage5 (
        .inRem   (rem_s4),
        .topBit  (A[2]),
        .divisor (B),
        .outRem  (rem_s5),
        .qBit    (qbit2)
    );

    
    div_stage stage6 (
        .inRem   (rem_s5),
        .topBit  (A[1]),
        .divisor (B),
        .outRem  (rem_s6),
        .qBit    (qbit1)
    );

    
    div_stage stage7 (
        .inRem   (rem_s6),
        .topBit  (A[0]),
        .divisor (B),
        .outRem  (rem_s7),
        .qBit    (qbit0)
    );

   
  
    wire [7:0] quotient_raw   = {qbit7, qbit6, qbit5, qbit4, qbit3, qbit2, qbit1, qbit0};
    wire [7:0] remainder_raw  = rem_s7[7:0];

    assign Q = (div_by_zero) ? 8'h00 : quotient_raw;
    assign R = (div_by_zero) ? 8'h00 : remainder_raw;

endmodule
