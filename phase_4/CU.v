module CONTROL_UNIT (
    input [31:0] instruction,    // 32-bit instruction input
    output reg [1:0] SRD,        // 2-bit Select target register
    output reg [1:0] PSW_LE_RE,  // 2-bit PSW Load / Read Enable
    output reg B,                // Branch
    output reg [2:0] SOH_OP,     // 3-bit Operand handler opcode
    output reg [3:0] ALU_OP,     // 4-bit ALU opcode
    output reg [3:0] RAM_CTRL,   // 4-bit Ram control
    output reg L,                // Select Dataout from RAM
    output reg RF_LE,            // Register File Load Enable
    output reg [1:0] ID_SR,      // 2-bit Instruction Decode Shift Register
    output reg UB,               // Unconditional Branch
    output reg SHF               // Shift
);
    // Second Opcode select for ALU operations
    task  set_alu_op(input [5:0] op2);
    begin
        // OP2 for ALU operations
        case (op2) 
            6'b011000: begin    // ADD
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b01;  // Load enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0000;   // A + B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b011100: begin    // ADDC
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b11;  // Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0001;   // A + B + Ci
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b101000: begin    // ADDL
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b00;  // NO Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0000;   // A + B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b010000: begin    // SUB
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b01;  // Load enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0010;   // A - B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b010100: begin    // SUBB
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b11;  // Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0011;   // A - B - Ci
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b001001: begin    // OR
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b00;  // NO Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0101;   // A | B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b001010: begin    // XOR
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b00;  // NO Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0110;   // A ^ B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end

            6'b001000: begin    // AND
            SRD = 2'b00;        // I[4:0]
            PSW_LE_RE = 2'b00;  // NO Load & write enabled
            B = 0;              // No branch
            SOH_OP = 3'b000;    // Pass through
            ALU_OP = 4'b0111;   // A & B
            RAM_CTRL = 4'b0000; // No RAM operation
            L = 0;              // No load
            RF_LE = 1;          // Load result into register
            ID_SR = 2'b11;      // Both registers are in use
            UB = 0;             // No unconditional branch
            SHF = 0;            // No shift   
            end
        endcase
    end
    endtask


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
        SHF = 0;

        // If instruction is NOP (all bits zero), keep signals at 0
        if (instruction != 32'h00000000) begin
            case (instruction[31:26])  // 6-bit opcode field
                6'b000010: begin // Three Register Arithmetic & Logical Instructions
                set_alu_op(instruction[11:6]);
                end

                6'b010010: begin    // LDW
                SRD = 2'b10;        // I[20:16] 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im4)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im4)
                RAM_CTRL = 4'b1001; // (10) Read word (0)WB (1)E 
                L = 1;              // Select RAM output 
                RF_LE = 1;          // Write to register 
                ID_SR = 2'b01;      // Use register 'a' 
                UB = 0;             // No unconditional branch  
                SHF = 0;            // No shift   
                end

                6'b010001: begin    // LDH
                SRD = 2'b10;        // I[20:16] 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im4)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im4)
                RAM_CTRL = 4'b0101; // (01) Read word (0)WB (1)E
                L = 1;              // Select RAM output 
                RF_LE = 1;          // Write to register 
                ID_SR = 2'b01;      // Use register 'a'  
                UB = 0;             // No unconditional branch  
                SHF = 0;            // No shift   
                end

                6'b010000: begin    // LDB
                SRD = 2'b10;        // I[20:16] 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im14)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im14)
                RAM_CTRL = 4'b0001; // (00) Read word (0)WB (1)E
                L = 1;              // Select RAM output 
                RF_LE = 1;          // Write to register 
                ID_SR = 2'b01;      // Use register 'a'  
                UB = 0;             // No unconditional branch 
                SHF = 0;            // No shift   
                end

                6'b001101: begin    // LDO
                SRD = 2'b10;        // I[20:16]
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im14)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im14)
                RAM_CTRL = 4'b0000; // (00) write word (0)WB (0)E
                L = 0;              // N/A
                RF_LE = 1;          // Write to register 
                ID_SR = 2'b01;      // Using register 'a' 
                UB = 0;             // No unconditional branch 
                SHF = 0;            // No shift   
                end

                6'b001000: begin    // LDIL
                SRD = 2'b01;        // I[25:21]
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b011;    // {I[20:0], 00000000000}
                ALU_OP = 4'b1010;   // Pass B
                RAM_CTRL = 4'b0000; // (00) write word (0)WB (0)E
                L = 0;              // N/A
                RF_LE = 1;          // Write to register 
                ID_SR = 2'b00;      // N/A 
                UB = 0;             // No unconditional branch
                SHF = 0;            // No shift   
                end

                6'b011010: begin    // STW
                SRD = 2'b11;        // N/A 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im14)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im14)
                RAM_CTRL = 4'b1011; // (10) write word (1)WB (1)E
                L = 0;              // N/A
                RF_LE = 0;          // N/A 
                ID_SR = 2'b11;      // Both registers 
                UB = 0;             // No unconditional branch 
                SHF = 0;            // No shift   
                end
                
                6'b011001: begin    // STH
                SRD = 2'b11;        // N/A 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im14)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im14)
                RAM_CTRL = 4'b0111; // (01) write half (1)WB (1)E
                L = 0;              // N/A
                RF_LE = 0;          // N/A 
                ID_SR = 2'b11;      // Both registers 
                UB = 0;             // No unconditional branch 
                SHF = 0;            // No shift   
                end
                
                6'b011000: begin    // STB
                SRD = 2'b11;        // N/A 
                PSW_LE_RE = 2'b00;  // N/A 
                B = 0;              // No branch
                SOH_OP = 3'b010;    // low_sign_ext(im14)
                ALU_OP = 4'b0000;   // A + low_sign_ext(im14)
                RAM_CTRL = 4'b0011; // (00) write byte (1)WB (1)E
                L = 0;              // N/A
                RF_LE = 0;          // N/A 
                ID_SR = 2'b11;      // Both registers 
                UB = 0;             // No unconditional branch 
                SHF = 0;            // No shift   
                end
                
                6'b111010: begin    // BL
                SRD = 2'b01;        // I[25:21]
                PSW_LE_RE = 2'b00;  // N/A
                B = 1;              // Branch
                SOH_OP = 3'b000;    // N/A
                ALU_OP = 4'b0000;   // N/A
                RAM_CTRL = 4'b0000; // N/A
                L = 0;              // N/A
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b00;      // N/A
                UB = 1;             // Unconditional branch
                SHF = 0;            // No shift   
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
                SHF = 0;            // No shift   
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
                SHF = 0;            // No shift   
                end

                6'b101101: begin    // ADDI
                SRD = 2'b10;        // I[20:16]
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b001;    // low_sign_ext(im11)
                ALU_OP = 4'b0000;   // A + B
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b01;      // A register in use
                UB = 0;             // No unconditional branch
                SHF = 0;            // No shift   
                end

                6'b100101: begin    // SUBI
                SRD = 2'b10;        // I[20:16]
                PSW_LE_RE = 2'b01;  // Load enabled
                B = 0;              // No branch
                SOH_OP = 3'b001;    // low_sign_ext(im11)
                ALU_OP = 4'b0100;   // B - A
                RAM_CTRL = 4'b0000; // No RAM operation
                L = 0;              // No load
                RF_LE = 1;          // Load result into register
                ID_SR = 2'b01;      // A register in use
                UB = 0;             // No unconditional branch
                SHF = 0;            // No shift   
                end

                6'b110100: begin
                    case (instruction[12:10])
                        3'b110: begin       // EXTRS
                        SRD = 2'b10;        // I[20:16]
                        PSW_LE_RE = 2'b00;  // N/A
                        B = 0;              // No branch
                        SOH_OP = 3'b101;    // shift right
                        ALU_OP = 4'b1010;   // Pass B
                        RAM_CTRL = 4'b0000; // No RAM operation
                        L = 0;              // No load
                        RF_LE = 1;          // Load result into register
                        ID_SR = 2'b10;      // B register in use
                        UB = 0;             // No unconditional branch
                        SHF = 1;            // Shift   
                        end

                        3'b111: begin       // EXTRU
                        SRD = 2'b10;        // I[20:16]
                        PSW_LE_RE = 2'b00;  // N/A
                        B = 0;              // No branch
                        SOH_OP = 3'b100;    // shift right unsigned
                        ALU_OP = 4'b1010;   // Pass B
                        RAM_CTRL = 4'b0000; // No RAM operation
                        L = 0;              // No load
                        RF_LE = 1;          // Load result into register
                        ID_SR = 2'b10;      // B register in use
                        UB = 0;             // No unconditional branch
                        SHF = 1;            // Shift   
                        end
                    endcase
                end

                default: ; // unknown opcode → no control
            endcase
        end
    end

    // initial begin
    //     $monitor("SRD: %b | PSW_LE_RE: %b | B: %b | SOH_OP: %b | ALU_OP: %b | RAM_CTRL: %b | L: %b | RF_LE: %b | ID_SR: %b | UB: %b | SHF: %b",
    //         SRD,
    //         PSW_LE_RE,
    //         B,
    //         SOH_OP,
    //         ALU_OP,
    //         RAM_CTRL,
    //         L,
    //         RF_LE,
    //         ID_SR,
    //         UB,
    //         SHF
    //     );
    // end

endmodule
