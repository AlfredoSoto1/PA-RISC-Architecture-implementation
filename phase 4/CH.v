module ConditionHandler (
    input wire B_in,
    input wire BL_in,
    input wire [3:0] I_Cond_in,

    input wire Z, N, C, V,

    output reg cond_eval,
    output reg TA_Ctrl_out,
    output reg BL_cond
);

    // Condition code constants
    parameter EQ  = 4'b0000;  // Z == 1
    parameter NE  = 4'b0001;  // Z == 0
    parameter CS  = 4'b0010;  // C == 1
    parameter CC  = 4'b0011;  // C == 0
    parameter MI  = 4'b0100;  // N == 1
    parameter PL  = 4'b0101;  // N == 0
    parameter VS  = 4'b0110;  // V == 1
    parameter VC  = 4'b0111;  // V == 0
    parameter AL  = 4'b1110;  // Always
    parameter NV  = 4'b1111;  // Never

    always @(*) begin
        // Default outputs
        cond_eval = 0;
        TA_Ctrl_out = 0;
        BL_cond = 0;

        // Condition evaluation
        case (I_Cond_in)
            EQ:  cond_eval = Z;
            NE:  cond_eval = ~Z;
            CS:  cond_eval = C;
            CC:  cond_eval = ~C;
            MI:  cond_eval = N;
            PL:  cond_eval = ~N;
            VS:  cond_eval = V;
            VC:  cond_eval = ~V;
            AL:  cond_eval = 1;
            NV:  cond_eval = 0;
            default: cond_eval = 0;
        endcase

        // Branching logic
        TA_Ctrl_out = (B_in || BL_in) && cond_eval;
        BL_cond = BL_in && cond_eval;
    end

endmodule
