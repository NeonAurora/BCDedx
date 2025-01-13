// File: controller_2bit.v
module controller_2bit (
    input  wire btnLoadA,
    input  wire btnLoadB,
    output wire loadA,
    output wire loadB
);
    // In a real design, this would be more complex, 
    // possibly an FSM that coordinates operation.
    assign loadA = btnLoadA;
    assign loadB = btnLoadB;
endmodule
