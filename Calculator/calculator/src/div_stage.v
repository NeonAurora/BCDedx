module div_stage (
    input  wire [8:0] inRem,    
    input  wire       topBit,   
    input  wire [7:0] divisor,  
    output wire [8:0] outRem,   
    output wire       qBit      
);														 
    wire [8:0] shifted = {inRem[7:0], topBit};
														   
    wire [8:0] divisor_9 = {1'b0, divisor};

    wire [8:0] diff;
    wire       borrow;

    ripple_sub_9bit sub9 (
        .x   (shifted),
        .y   (divisor_9),
        .diff(diff),
        .borrow(borrow)
    );
											   
    assign qBit   = ~borrow;
    assign outRem = borrow ? shifted : diff;
endmodule
