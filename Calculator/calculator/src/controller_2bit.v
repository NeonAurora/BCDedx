module controller_2bit (
    input  wire btnLoadA,
    input  wire btnLoadB,
    output wire loadA,
    output wire loadB,

    input  wire [1:0] op,

    output wire selAdd,  
    output wire selSub, 
    output wire selMul,  
    output wire selDiv   
);
    assign loadA = btnLoadA;
    assign loadB = btnLoadB;

    assign selAdd = (op == 2'b00);
    assign selSub = (op == 2'b01);
    assign selMul = (op == 2'b10);
    assign selDiv = (op == 2'b11);
endmodule
