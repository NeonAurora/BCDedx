module controller_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire       btnLoadA,   // load button for A
    input  wire       btnLoadB,   // load button for B
    input  wire [1:0] op,         // 00=Add, 01=Sub, 10=Mul, 11=Div
    // outputs to registers
    output reg        loadA,
    output reg        loadB,
    // outputs to orchestrate multiply
    output reg        mulStart,
    output reg        mulDone
);

    // State encoding
    localparam S_IDLE      = 3'd0;
    localparam S_LOAD      = 3'd1;
    localparam S_CHECK_OP  = 3'd2;
    localparam S_MUL_INIT  = 3'd3;
    localparam S_MUL_LOOP  = 3'd4;
    localparam S_MUL_DONE  = 3'd5;

    reg [2:0] state, nextState;

    // Synchronous state register
    always @(posedge clk or posedge rst) begin
        if (rst) state <= S_IDLE;
        else     state <= nextState;
    end

    // Next-state logic plus output logic
    always @(*) begin
        // Default outputs
        loadA    = 1'b0;
        loadB    = 1'b0;
        mulStart = 1'b0;
        mulDone  = 1'b0;

        nextState = state; // default hold

        case (state)
        // ---------------------------------------------------------
        //  S_IDLE: 
        //   - Wait here until the user presses either load button
        //     so we can go to a dedicated "LOAD" state
        // ---------------------------------------------------------
        S_IDLE: begin
            if (btnLoadA || btnLoadB) begin
                nextState = S_LOAD;
            end else begin
                nextState = S_IDLE; // remain
            end
        end

        // ---------------------------------------------------------
        //  S_LOAD:
        //   - As long as user is pressing btnLoadA or btnLoadB,
        //     we assert loadA/loadB = 1. 
        //   - Once user releases both (btnLoadA=0, btnLoadB=0),
        //     we move to S_CHECK_OP.
        // ---------------------------------------------------------
        S_LOAD: begin
            // Let the registers latch data
            loadA = btnLoadA;
            loadB = btnLoadB;

            // Remain here until both buttons are released
            if (!btnLoadA && !btnLoadB) begin
                nextState = S_CHECK_OP;
            end else begin
                nextState = S_LOAD;
            end
        end

        // ---------------------------------------------------------
        //  S_CHECK_OP:
        //   - Check the 'op' lines
        //   - If op=10 => go to S_MUL_INIT
        //   - else => back to S_IDLE (the ALU might do add/sub/div
        //     combinationally, or in one cycle)
        // ---------------------------------------------------------
        S_CHECK_OP: begin
            if (op == 2'b10) begin
                nextState = S_MUL_INIT;
            end else begin
                nextState = S_IDLE;  // or remain in S_CHECK_OP
            end
        end

        // ---------------------------------------------------------
        //  S_MUL_INIT:
        //   - We set mulStart=1 for 1 cycle to let the ALU
        //     or repeated-sum logic initialize 
        // ---------------------------------------------------------
        S_MUL_INIT: begin
            mulStart  = 1'b1;
            // next cycle => S_MUL_LOOP
            nextState = S_MUL_LOOP;
        end

        // ---------------------------------------------------------
        //  S_MUL_LOOP:
        //   - The multiply logic does repeated sum. We'll assume
        //     it runs for multiple cycles until it sets a "done"
        //     flag. For this example, we move to S_MUL_DONE quickly.
        //   - You might have an external "mul_done_flag" from the ALU.
        // ---------------------------------------------------------
        S_MUL_LOOP: begin
            // If you have an external "mul_done_flag" from the ALU,
            // do: if (mul_done_flag) nextState = S_MUL_DONE; else stay
            // For demonstration, let's do a single cycle
            nextState = S_MUL_DONE;
        end

        // ---------------------------------------------------------
        //  S_MUL_DONE:
        //   - The ALU has the final product. We set mulDone=1 for 1 cycle
        //   - Then return to S_IDLE
        // ---------------------------------------------------------
        S_MUL_DONE: begin
            mulDone   = 1'b1;
            nextState = S_IDLE;
        end

        default: nextState = S_IDLE;
        endcase
    end

endmodule
