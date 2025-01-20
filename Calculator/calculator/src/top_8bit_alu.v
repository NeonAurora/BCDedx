module top_8bit_alu (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] inA,
    input  wire [7:0] inB,
    input  wire       btnLoadA,
    input  wire       btnLoadB,
    input  wire [1:0] op, 
    output wire [15:0] led_out,
    output wire        flag_out
);

   
    wire loadA_sig, loadB_sig;
    wire selAdd, selSub, selMul, selDiv;

  
    controller_2bit controller_inst (
        .btnLoadA(btnLoadA),
        .btnLoadB(btnLoadB),
        .loadA(loadA_sig),
        .loadB(loadB_sig),
        
        .op(op),
        .selAdd(selAdd),
        .selSub(selSub),
        .selMul(selMul),
        .selDiv(selDiv)
    );

   
    wire [7:0] regA_out, regB_out;

    register_8bit regA (
        .clk(clk),
        .rst(rst),
        .load(loadA_sig),
        .d(inA),
        .q(regA_out)
    );

    register_8bit regB (
        .clk(clk),
        .rst(rst),
        .load(loadB_sig),
        .d(inB),
        .q(regB_out)
    );

  
    wire [15:0] alu_result;
    wire        alu_status;

    alu_8bit alu_inst (
        .a(regA_out),
        .b(regB_out),
        .selAdd(selAdd),
        .selSub(selSub),
        .selMul(selMul),
        .selDiv(selDiv),
        .result(alu_result),
        .status(alu_status)
    );

    
    assign led_out  = alu_result;
    assign flag_out = alu_status;

endmodule
