module CONTROL_UNIT (
    input wire [31:0] instruction, // 32-bit instruction input
    output logic [1:0] SRD,        // 2-bit Select target register
    output logic [1:0] PSW_LE_RE,  // 2-bit PSW Load / Read Enable
    output logic B,                // Branch
    output logic [2:0] SOH_OP,     // 3-bit Operand handler opcode
    output logic [3:0] ALU_OP,     // 4-bit ALU opcode
    output logic [3:0] RAM_CTRL,   // 4-bit Ram control
    output logic L,                // Select Dataout from RAM
    output logic RF_LE,            // Register File Load Enable
    output logic [1:0] ID_SR,      // 2-bit Instruction Decode Shift Register
    output logic UB,               // Unconditional Branch
);
    always @* begin
        // Default all signals to 0 (NOP behavior)
        SRD = 2'b00;
        PSW_LE_RE = 2'b00;
        B = 0;
        SOH_OP = 3'b000;
        ALU_OP = 4'b0000;
        RAM_CTRL = 4'b0000;
        L = 0;
        RF_LE = 0;
        ID_SR = 2'b00;
        UB = 0;

        // If instruction is NOP (all bits zero), keep signals at 0
        if (instruction != 32'h00000000) begin
            case (instruction[31:26])  // 6-bit opcode field
                6'b011000: begin    // ADD
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0000;   // A + B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b011100: begin    // ADDC
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b11;  // Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0001;   // A + B + Ci
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b101000: begin    // ADDL
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b00;  // NO Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0000;   // A + B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b010000: begin    // SUB
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0010;   // A - B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b010100: begin    // SUBB
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b11;  // Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0011;   // A - B - Ci
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b001001: begin    // OR
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b00;  // NO Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0101;   // A | B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end
                6'b001010: begin    // XOR
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b00;  // NO Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0110;   // A ^ B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b001000: begin    // AND
                SRD = 2'b00;        // Select destination register
                PSW_LE_RE = 2'b00;  // NO Load & write enabled
                B = 0;              // No branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0111;   // A & B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end


                6'b000000: begin // LDW
                end
                6'b000000: begin // LDH
                end
                6'b000000: begin // LDB
                end
                6'b000000: begin // LDO
                end
                6'b000000: begin // LDIL
                end
                6'b000000: begin // STW
                end
                6'b000000: begin // STH
                end
                6'b000000: begin // STB
                end
                6'b111010: begin    // BL
                SRD = 2'b01;        // Select destination register
                PSW_LE_RE = 2'b00;  // N/A
                B = 1;              // Branch
                SOH_OP = 3'b000;    // N/A
                ALU_OP = 4'b0000;   // N/A
                RAM_CTRL = 4'b0000; // N/A
                L = 0;              // N/A
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b00;      // N/A
                UB = 1;             // Unconditional branch
                end

                6'b100000: begin    // COMBT
                SRD = 2'b11;        // N/A
                PSW_LE_RE = 2'b00;  // N/A
                B = 1;              // Branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0010;   // A - B
                RAM_CTRL = 4'b0000; // N/A
                L = 0;              // N/A
                RF_LE = 0;          // N/A
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b100010: begin    // COMBF
                SRD = 2'b11;        // N/A
                PSW_LE_RE = 2'b00;  // N/A
                B = 1;              // Branch
                SOH_OP = 3'b000;    // Pass through
                ALU_OP = 4'b0010;   // A - B
                RAM_CTRL = 4'b0000; // N/A
                L = 0;              // N/A
                RF_LE = 0;          // N/A
                ID_SR = 2'b11;      // Both registers are in use
                UB = 0;             // No unconditional branch
                end

                6'b101101: begin    // ADDI
                SRD = 2'b10;        // Select destination register
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b001;    // low_sign_ext(im11)
                ALU_OP = 4'b0000;   // A + B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b01;      // A register in use
                UB = 0;             // No unconditional branch
                end

                6'b100101: begin    // SUBI
                SRD = 2'b10;        // Select destination register
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b001;    // low_sign_ext(im11)
                ALU_OP = 4'b0000;   // A + B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b01;      // A register in use
                UB = 0;             // No unconditional branch
                end
                6'b000000: begin // EXTRU
                end
                6'b000000: begin // EXTRS
                end
                6'b000000: begin // ZDEP
                end

                default: ; // unknown opcode → no control
            endcase
        end
    end

endmodule
