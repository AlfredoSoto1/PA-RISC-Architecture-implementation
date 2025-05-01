module CH (
    input wire NEG_COND,    // Negate condition
    input wire B,           // Branch instruction
    input wire Odd,         // Odd Result
    input wire Z, N, C, V,  // ALU Flags  
    input wire [2:0] Cond,  // Condition code
    
    output reg J            // Jump desition
);

    always @(*) begin
        case (Cond)
            3'b000: J = 0;              // Never
            3'b001: J = Z;              // GR[r1] is equal to GR[r2]
            3'b010: J = (N != V);       // GR[r1] is les than GR[r2] (signed)
            3'b011: J = Z | (N != V);   // GR[r1] is les tan or equal GR[r2] (signed)
            3'b100: J = C;              // GR[r1] is les than GR[r2] (unsigned)
            3'b101: J = Z | C;          // GR[r1] is les tan or equal GR[r2] (unsigned)
            3'b110: J = V;              // GR[r1] - GR[r2] overflows (unsigned)
            3'b111: J = Odd;            // GR[r1] - GR[r2] is odd
        endcase

        J = NEG_COND == 1 ? ~J : J;

        if (B == 0) begin
            J = 0; // No Jump
        end
    end
endmodule