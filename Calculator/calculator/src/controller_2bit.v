// File: controller_2bit.v
module controller_2bit (
    input  wire btnLoadA,
    input  wire btnLoadB,
    output wire loadA,
    output wire loadB
);
    assign loadA = btnLoadA;
    assign loadB = btnLoadB;
endmodule
