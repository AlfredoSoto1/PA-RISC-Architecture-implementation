
module ALU (
    input [31:0] A,         // 32-bit register
    input [31:0] B,         // 32-bit register
    input Ci,               // Carry bit
    input [3:0] OP,         // OP-Code
    output reg [31:0] Out,  // 32-bit register
    output reg Z, N, C, V   // 4-bit flag register
);

    reg [32:0] temp = 33'h0; // Temporary register to store extended sum for carry

    always @(*) begin
        case (OP)
            4'b0000: temp = A + B;       // (With flags) Addition
            4'b0001: temp = A + B + Ci;  // (With flags) Addition with carry
            4'b0010: temp = A - B;       // (With flags) Subtraction
            4'b0011: temp = A - B - Ci;  // (With flags) Subtraction with carry
            4'b0100: temp = B - A;       // Subtraction flipped
            4'b0101: Out = A | B;        // OR
            4'b0110: Out = A ^ B;        // XOR
            4'b0111: Out = A & B;        // AND
            4'b1000: Out = A;            // Pass A
            4'b1001: Out = A + 8;        // Shift A 8 places forward
            4'b1010: Out = B;            // Pass B
            default: Out = 32'h00000000; // Default case
        endcase
        
        // Set to zero if OP doesnt match if condition
        V = 0; // Always set to zero
        C = 0; // Always set to zero
        
        // Handle OutCarry for arigmethic operations
        case (OP)
            4'b0000: begin
                Out = temp[31:0]; // Pass out the operation result
                C = temp[32];  
                V = (~(A[31] ^ B[31])) & (A[31] ^ Out[31]); // Overflow for sum
            end
            4'b0001: begin
                Out = temp[31:0]; // Pass out the operation result
                C = temp[32];
                V = (~(A[31] ^ B[31])) & (A[31] ^ Out[31]); // Overflow for sum
            end
            4'b0010: begin
                Out = temp[31:0]; // Pass out the operation result
                C = (A < B) ? 1 : 0;
                V = (A[31] ^ B[31]) & (A[31] ^ Out[31]); // Overflow for sub
            end
            4'b0011: begin
                Out = temp[31:0]; // Pass out the operation result
                C = (A < (B + Ci)) ? 1 : 0;
                V = (A[31] ^ B[31]) & (A[31] ^ Out[31]); // Overflow for sub
            end
            4'b0100: begin
                Out = temp[31:0]; // Pass out the operation result
                C = (A > B) ? 1 : 0;
            end
        endcase
        
        Z = (Out == 32'h00000000) ? 1 : 0; // Zero flag
        N = Out[31];                       // Sign flag
    end
endmodule