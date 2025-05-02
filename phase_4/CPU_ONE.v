////////////////////////////// ROM  //////////////////////////////////

module ROM (
    output reg [31:0] I, // Salida de 32 bits (word)
    input [7:0] A        // Dirección de 8 bits (256 localizaciones)
);

    // Memoria de 256 bytes (8 bits cada celda)
    reg [7:0] Mem[0:255]; 

    // Precarga de la memoria desde un archivo de texto externo 
    initial begin
        // $readmemb("test_1_instructions.txt", Mem);
        $readmemb("test_2_instructions.txt", Mem);
        // $readmemb("test_3_instructions.txt", Mem);
    end

    // Lectura de una instrucción completa (word) en big-endian
    always @(*) begin
        I = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
    end

endmodule

////////////////////////////// RAM  //////////////////////////////////

module RAM256x8 (
    output reg [31:0] DataOut, // 32 bit data output
    input Enable,              // enabling signal
    input ReadWrite,           // 0: Read, 1: Write
    input [7:0] Address,       // 8 bit memory address from [0, 255]
    input [1:0] Size,          // 00: byte, 01: halfword, 10: word
    input [31:0] DataIn        // 32 bit data input
);
    
    reg [7:0] Mem[0:255]; // Memoria de 256 bytes

    // Precarga de memoria desde un archivo de texto
    initial begin
        // $readmemb("test_1_instructions.txt", Mem);
        $readmemb("test_2_instructions.txt", Mem);
        // $readmemb("test_3_instructions.txt", Mem);
    end

    always @(*) begin
        // Read from memory if ReadWrite is enabled
        // use bigendian as manual suggests
        if (Enable && !ReadWrite) begin
            case (Size)
                2'b00: DataOut = {24'b0, Mem[Address]}; // Byte
                2'b01: DataOut = {16'b0, Mem[Address], Mem[Address+1]}; // Halfword
                2'b10: DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]}; // Word
                default: DataOut = 32'b0;
            endcase
        end

   // always @(posedge Enable) begin
        // Write to memory if ReadWrite is enabled
        // use bigendian as manual suggests
        if (ReadWrite && Enable) begin
            case (Size)
                2'b00: Mem[Address] <= DataIn[7:0]; // Byte
                2'b01: begin // Halfword (big-endian)
                    Mem[Address]   <= DataIn[15:8];
                    Mem[Address+1] <= DataIn[7:0];
                end
                2'b10: begin // Word (big-endian)
                    Mem[Address]   <= DataIn[31:24];
                    Mem[Address+1] <= DataIn[23:16];
                    Mem[Address+2] <= DataIn[15:8];
                    Mem[Address+3] <= DataIn[7:0];
                end
            endcase
        end
    end
endmodule


////////////////////////////// PC ADDER  //////////////////////////////////

module PC_ADDER (
    input [7:0] currPC, // Current Program Counter
    output [7:0] nextPC // Next Program Counter
);
    assign nextPC = currPC + 4; // Add 4 to the current PC
endmodule

////////////////////////////// PIPELINE REGISTERS  //////////////////////////////////

module PC_FRONT_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'h00;      // Synchronous reset to 0
        else if (LE)
            Q <= D;          // Load input value if LE is high
    end
endmodule


module PC_BACK_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'd4;       // Initialize to 4 on reset
        else if (LE)
            Q <= D;          // Load new value if enabled
    end
endmodule


module IF_ID_REGISTER (
    input wire LE, Rst, Clk,               // Load enable, synchronous reset, clock
    input wire CLR,                        // Clear signal
    input wire [7:0]  front_address,       // 8-bit input
    input wire [31:0] fetched_instruction, // 32-bit input
    
    output reg [7:0]  B_PC,                // 8-bit output 
    output reg [31:0] instruction          // 32-bit output 
);
    always @(posedge Clk) begin
        if (Rst || CLR) begin
            B_PC <= 8'h0;                     
            instruction <= 32'h0;               
        end else if (LE) begin
            B_PC <= front_address; 
            instruction <= fetched_instruction; 
        end
    end
endmodule


module ID_EX_REG (
    input wire clk, reset,

    // Register values and addresses
    input wire [31:0] RA_in,
    input wire [31:0] RB_in,
    input wire [7:0] TA_in,
    input wire [7:0] R_in,

    // Condition and Immediate values
    input wire [4:0] RD_in,
    input wire [2:0] COND_in,
    input wire [20:0] IM_in,

    // Control signals from mux
    input wire [1:0] PSW_LE_RE_in,
    input wire B_in,
    input wire [2:0] SOH_OP_in,
    input wire [3:0] ALU_OP_in,
    input wire [3:0] RAM_CTRL_in,
    input wire L_in,
    input wire RF_LE_in,
    input wire UB_in,
    input wire NEG_COND_in,

    // Output Register values and addresses
    output reg [31:0] RA_out,
    output reg [31:0] RB_out,
    output reg [7:0] TA_out,
    output reg [7:0] R_out,

    // Output condition and Immediate values
    output reg [4:0] RD_out,
    output reg [2:0] COND_out,
    output reg [20:0] IM_out,

    // Outputs to EX stage
    output reg [1:0] PSW_LE_RE_out,
    output reg B_out,
    output reg [2:0] SOH_OP_out,
    output reg [3:0] ALU_OP_out,
    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out,
    output reg UB_out,
    output reg NEG_COND_out
);

    always @(posedge clk) begin
        if (reset) begin

            RA_out <= 0;
            RB_out <= 0;
            TA_out <= 0;
            R_out <= 0;

            RD_out <= 0;
            COND_out <= 0;
            IM_out <= 0;

            PSW_LE_RE_out <= 0;
            B_out <= 0;
            SOH_OP_out <= 0;
            ALU_OP_out <= 0;
            RAM_CTRL_out <= 0;
            L_out <= 0;
            RF_LE_out <= 0;
            UB_out <= 0;
            NEG_COND_out <= 0;
        end else begin

            RA_out <= RA_in;
            RB_out <= RB_in;
            TA_out <= TA_in;
            R_out <= R_in;

            RD_out <= RD_in;
            COND_out <= COND_in;
            IM_out <= IM_in;

            PSW_LE_RE_out <= PSW_LE_RE_in;
            B_out <= B_in;
            SOH_OP_out <= SOH_OP_in;
            ALU_OP_out <= ALU_OP_in;
            RAM_CTRL_out <= RAM_CTRL_in;
            L_out <= L_in;
            RF_LE_out <= RF_LE_in;
            UB_out <= UB_in;
            NEG_COND_out <= NEG_COND_in;
        end
    end
endmodule

module PSW_REG (
  input wire clk,    // Clock signal
  input wire LE,     // Load enable signal
  input wire RE,     // Read enable signal
  input wire C_in,   // Data input (1-bit wide, C/B)
  output wire C_out  // Data output (1-bit wide, C/B)
);

  reg register; // Internal register to store 1-bit data

  // Load data into the register on the rising edge of the clock
  always @(posedge clk) begin
    if (LE) begin
      register <= C_in;
    end
  end

  // Output data only when read enable is high
  assign C_out = RE ? register : 1'b0;

endmodule

module EX_MEM_REG (
    input wire clk, reset,

    input wire [31:0] EX_OUT,
    input wire [31:0] EX_DI,
    input wire [4:0]  EX_RD,

    input wire L,
    input wire RF_LE,
    input wire [3:0] RAM_CTRL,

    output reg [31:0] EX_OUT_IN,
    output reg [31:0] EX_DI_IN,
    output reg [4:0]  EX_RD_IN,
    output reg L_IN,
    output reg RF_LE_IN,
    output reg [3:0] RAM_CTRL_IN
);

    always @(posedge clk) begin
        if (reset) begin
            EX_OUT_IN <= 0;
            EX_DI_IN <= 0;
            EX_RD_IN <= 0;
            L_IN <= 0;
            RF_LE_IN <= 0;
            RAM_CTRL_IN <= 0;
        end else begin
            EX_OUT_IN <= EX_OUT;
            EX_DI_IN <= EX_DI;
            EX_RD_IN <= EX_RD;
            L_IN <= L;
            RF_LE_IN <= RF_LE;
            RAM_CTRL_IN <= RAM_CTRL;
        end
    end
endmodule


module MEM_WB_REG (
    input wire clk, reset,

    input wire [4:0]  MEM_RD,
    input wire [31:0] MEM_OUT,
    input wire MEM_RF_LE,

    output reg [4:0]  WB_RD,
    output reg [31:0] WB_OUT,
    output reg WB_RF_LE
);

    always @(posedge clk) begin
        if (reset) begin
            WB_RD <= 0;
            WB_OUT <= 0;
            WB_RF_LE <= 0;
        end else begin
            WB_RD <= MEM_RD;
            WB_OUT <= MEM_OUT;
            WB_RF_LE <= MEM_RF_LE;
        end
    end
endmodule


////////////////////////////// CU  //////////////////////////////////


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
    output reg SHF,              // Shift
    output reg NEG_COND          // Negate condition
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
        NEG_COND = 0;

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
                NEG_COND = 0;       // Keep condition true
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
                NEG_COND = 1;       // Negate the condition
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

                6'b110101: begin
                    SRD = 2'b10;        // I[20:16]
                    PSW_LE_RE = 2'b00;  // N/A
                    B = 0;              // No branch
                    SOH_OP = 3'b110;    // shift left
                    ALU_OP = 4'b1010;   // Pass B
                    RAM_CTRL = 4'b0000; // No RAM operation
                    L = 0;              // No load
                    RF_LE = 1;          // Load result into register
                    ID_SR = 2'b10;      // B register in use
                    UB = 0;             // No unconditional branch
                    SHF = 1;            // Shift   
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


////////////////////////////// TAG  //////////////////////////////////

module TAG_ADDER (
    input wire [7:0] B_PC,
    output wire [7:0] R
);
    assign R = B_PC + 8;
endmodule


module TAG (
    input [7:0] B_PC,
    input wire [20:0] offset,
    output reg [7:0] TA,
    output wire [7:0] R
);

    reg [31:0] TA_temp; // Temporary target address

    TAG_ADDER tag_adder (
        .B_PC(B_PC),
        .R(R)
    ); 

    function [31:0] sign_ext;
        input [20:0] in; // Replace N with actual bit width
        begin
            sign_ext = {{(32-20){in[20]}}, in};
        end
    endfunction

    always @(*) begin
        // Calculate the target address (TA) based on the offset and return address
        case (offset[15:13])
            3'b000: begin
                // TA = B_PC + 8 + 4 x sign_ext(w1,w2,w);
                // Shift left by 2 bits to multiply by 4
                TA_temp <= R + (sign_ext({offset[20:16], offset[12:2], offset[0]}) << 2); 
            end
            default:
                // TA = B_PC + 8 + 4 x sign_ext(w1,w);
                TA_temp <= R + (sign_ext({offset[12:2], offset[0]}) << 2);
        endcase

        TA <= TA_temp[7:0]; // Assign the lower 8 bits of the target address
    end
endmodule


////////////////////////////// ALU  //////////////////////////////////


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

////////////////////////////// OH  //////////////////////////////////

module OperandHandler (
    input  wire [31:0] RB,  // RB: 32-bit (register)
    input  wire [20:0] I,   // I (input)
    input  wire [2:0] S,    // S (select)
    output reg  [31:0] N    // N (out)
);
    wire [4:0] shift_amt;         // Shift amount (31 - I[9:5])
    wire [31:0] low_sign_ext_11;  // Sign-extended I[10:0]
    wire [31:0] low_sign_ext_14;  // Sign-extended I[13:0]
    wire [31:0] shift_right_logic;
    wire [31:0] shift_right_arith;
    wire [31:0] shift_left_logic;

    assign low_sign_ext_11 = {{22{I[0]}}, I[10:1]};        // Sign-extend I[10:0] to 32 bits
    assign low_sign_ext_14 = {{19{I[0]}}, I[13:1]};        // Sign-extend I[13:0] to 32 bits
    
    assign shift_amt = 31 - I[9:5];
    assign shift_right_logic = RB >> shift_amt;            // Logical shift right
    assign shift_right_arith = $signed(RB) >>> shift_amt;  // Arithmetic shift right (sign extended)
    assign shift_left_logic  = RB << shift_amt;            // Logical shift left

    always @* begin
        case (S)
            3'b000: N = RB;
            3'b001: N = low_sign_ext_11;
            3'b010: N = low_sign_ext_14;
            3'b011: N = {I[20:0], 11'b0};
            3'b100: N = shift_right_logic;
            3'b101: N = shift_right_arith;
            3'b110: N = shift_left_logic;
            3'b111: N = 32'b0;  // Not used, set to 0
            default: N = 32'b0;
        endcase
    end
endmodule

////////////////////////////// CH //////////////////////////////////

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


////////////////////////////// MUXES //////////////////////////////////

module MUX_CU (
    input wire S,

    input wire [1:0] PSW_LE_RE_in,
    input wire B_in,
    input wire [2:0] SOH_OP_in,
    input wire [3:0] ALU_OP_in,
    input wire [3:0] RAM_CTRL_in,
    input wire L_in,
    input wire RF_LE_in,
    input wire UB_in,
    input wire SHF_in,
    input wire NEG_COND_in,

    output reg [1:0] PSW_LE_RE_out,
    output reg B_out,
    output reg [2:0] SOH_OP_out,
    output reg [3:0] ALU_OP_out,
    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out,
    output reg UB_out,
    output reg SHF_out,
    output reg NEG_COND_out
);

    always @(*) begin
        if (S == 1'b1) begin
            PSW_LE_RE_out = 2'b00;
            B_out = 1'b0;
            SOH_OP_out = 3'b000;
            ALU_OP_out = 4'b0000;
            RAM_CTRL_out = 4'b0000;
            L_out = 1'b0;
            RF_LE_out = 1'b0;
            UB_out = 1'b0;
            SHF_out = 1'b0;
            NEG_COND_out = 1'b0;
        end else begin
            PSW_LE_RE_out = PSW_LE_RE_in;
            B_out = B_in;
            SOH_OP_out = SOH_OP_in;
            ALU_OP_out = ALU_OP_in;
            RAM_CTRL_out = RAM_CTRL_in;
            L_out = L_in;
            RF_LE_out = RF_LE_in;
            UB_out = UB_in;
            SHF_out = SHF_in;
            NEG_COND_out = NEG_COND_in;
        end
    end
endmodule


module MUX_IF (
    input wire S,           // Jump signal
    input wire [7:0] TA,    // Target Address
    input wire [7:0] back,  // Back Address

    output reg [7:0] O      // Output Address
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= TA;
        end else begin
            O <= back;
        end
    end
endmodule


module MUX_ID_IDR (
    input wire [1:0] S,     // Select slot for target register
    input wire [4:0] I_0,   // I[4:0]
    input wire [4:0] I_1,   // I[25:21]
    input wire [4:0] I_2,   // I[20:16]

    output reg [4:0] IDR    // Target Register
);

    always @(*) begin
        case (S)
            2'b00: IDR <= I_0; // I[4:0]
            2'b01: IDR <= I_1; // I[25:21]
            2'b10: IDR <= I_2; // I[20:16]
            default: IDR <= 8'b00000000; // Default case
        endcase
    end
endmodule

module MUX_ID_SHF (
    input wire S,   // Select slot for SHF register
    input wire [4:0] RA,  // Register A 
    input wire [4:0] RB,  // Register B 

    output reg [4:0] O    // Register for shifting
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= RA;     
        end else begin
            O <= RB;     
        end
    end
endmodule

module MUX_ID_FW_P (
    input wire [1:0] S,    // Select slot for P register
    input wire [31:0] RP,   // 
    input wire [31:0] EX,   // 
    input wire [31:0] MEM,  // 
    input wire [31:0] WB,   // 

    output reg [31:0] FW_P  // Forwarding Data from Register
);

    always @(*) begin
        case (S)
            2'b00: FW_P <= RP;  // Register P
            2'b01: FW_P <= EX;  // Register EX
            2'b10: FW_P <= MEM; // Register MEM
            2'b11: FW_P <= WB;  // Register WB
            default: FW_P <= 5'b00000; // Default case
        endcase
    end
endmodule

module MUX_EX_J (
    input wire S, // Select slot for P register
    input wire J, // Jump flag (only for conditional jumps) 

    output reg O  // Jump signal 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= 1'b1;  // Always jump
        end else begin
            O <= J;     // Jump signal
        end
    end
endmodule

module MUX_EX_RETURN_ADDRESS (
    input wire S,          // Select return address or ALU output
    input wire [7:0]  R,   // Return address 
    input wire [31:0] ALU, // ALU output 

    output reg [31:0] O    // 32 bit output data 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= {24'b0, R};  // Return address
        end else begin
            O <= ALU; // ALU output
        end
    end
endmodule


module MUX_MEM (
    input wire S,           // Select ram output or EX output
    input wire [31:0] DO,   // Data out from memory 
    input wire [31:0] EX,   // EX output 

    output reg [31:0] O     // 32 bit output data 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= DO;  // Data out from memory
        end else begin
            O <= EX;  // EX output
        end
    end
endmodule

////////////////////////////// TP_REGISTER_FILE  //////////////////////////////////

module RF_MUX32x1 (
    output reg [31:0] P,      // 32-bit output
    input [4:0] S,            // 5-bit selection input 
    input [31:0] R0,R1,R2,R3, // 32 inputs, each 32-bit wide
                 R4,R5,R6,R7, 
                 R8,R9,R10,R11,
                 R12,R13,R14,R15,
                 R16,R17,R18,R19,
                 R20,R21,R22,R23,
                 R24,R25,R26,R27,
                 R28,R29,R30,R31     
);

    always @(*) begin
        // Select the input based on the selection value
        case (S)
            5'b00000: P = R0;
            5'b00001: P = R1;  
            5'b00010: P = R2;
            5'b00011: P = R3;
            5'b00100: P = R4;
            5'b00101: P = R5;
            5'b00110: P = R6;
            5'b00111: P = R7;
            5'b01000: P = R8;
            5'b01001: P = R9;
            5'b01010: P = R10;
            5'b01011: P = R11;
            5'b01100: P = R12;
            5'b01101: P = R13;
            5'b01110: P = R14;
            5'b01111: P = R15;
            5'b10000: P = R16;
            5'b10001: P = R17;
            5'b10010: P = R18;
            5'b10011: P = R19;
            5'b10100: P = R20;
            5'b10101: P = R21;
            5'b10110: P = R22;
            5'b10111: P = R23;
            5'b11000: P = R24;
            5'b11001: P = R25;
            5'b11010: P = R26;
            5'b11011: P = R27;
            5'b11100: P = R28;
            5'b11101: P = R29;
            5'b11110: P = R30;
            5'b11111: P = R31;
        endcase 
    end
endmodule

module RF_DECODER5x32 (
    output reg [31:0] O, // 32-bit output
    input [4:0] D,       // 5-bit input
    input E              // Enable input
);
    always @* begin
        // If enable is 0, output is 0
        // Otherwise, output is 2^D
        if (E == 0) 
            O = 32'b0;
        else begin
            case (D)
                5'b00000: O = 32'b00000000000000000000000000000001;
                5'b00001: O = 32'b00000000000000000000000000000010;
                5'b00010: O = 32'b00000000000000000000000000000100;
                5'b00011: O = 32'b00000000000000000000000000001000;
                5'b00100: O = 32'b00000000000000000000000000010000;
                5'b00101: O = 32'b00000000000000000000000000100000;
                5'b00110: O = 32'b00000000000000000000000001000000;
                5'b00111: O = 32'b00000000000000000000000010000000;
                5'b01000: O = 32'b00000000000000000000000100000000;
                5'b01001: O = 32'b00000000000000000000001000000000;
                5'b01010: O = 32'b00000000000000000000010000000000;
                5'b01011: O = 32'b00000000000000000000100000000000;
                5'b01100: O = 32'b00000000000000000001000000000000;
                5'b01101: O = 32'b00000000000000000010000000000000;
                5'b01110: O = 32'b00000000000000000100000000000000;
                5'b01111: O = 32'b00000000000000001000000000000000;
                5'b10000: O = 32'b00000000000000010000000000000000;
                5'b10001: O = 32'b00000000000000100000000000000000;
                5'b10010: O = 32'b00000000000001000000000000000000;
                5'b10011: O = 32'b00000000000010000000000000000000;
                5'b10100: O = 32'b00000000000100000000000000000000;
                5'b10101: O = 32'b00000000001000000000000000000000;
                5'b10110: O = 32'b00000000010000000000000000000000;
                5'b10111: O = 32'b00000000100000000000000000000000;
                5'b11000: O = 32'b00000001000000000000000000000000;
                5'b11001: O = 32'b00000010000000000000000000000000;
                5'b11010: O = 32'b00000100000000000000000000000000;
                5'b11011: O = 32'b00001000000000000000000000000000;
                5'b11100: O = 32'b00010000000000000000000000000000;
                5'b11101: O = 32'b00100000000000000000000000000000;
                5'b11110: O = 32'b01000000000000000000000000000000;
                5'b11111: O = 32'b10000000000000000000000000000000;
                default: O = 32'b0;
            endcase
        end
    end
endmodule

module RF_REGISTER32 (
    output reg [31:0] Q,     // 32-bit output 
    output wire signed [31:0] Q_S,  // 32-bit signed output 
    input wire [31:0] D,     // 32-bit input
    input wire LE, Clr, Clk  // Load enable, clear, clock
);
    always @(posedge Clk) begin
        if (Clr) 
            // If clear is high, reset the register to 0
            Q <= 32'h00000000;
        else if (LE) 
            // If load enable is high, store the input value
            Q <= D;
    end

    assign Q_S = Q;
endmodule

module TP_REGISTER_FILE (
    output [31:0] PA, PB,    // 32-bit Output ports
    input [31:0] PW,         // 32-bit Input port
    input [4:0] RA, RB, RW,  // 5-bit  Input ports
    input Clk, LE            // Clock and Load Enable
);
    wire [31:0] O;                   // 32-bit output wire to load enable the registers
    wire [31:0] Qs0,Qs1,Qs2,Qs3,     // 32-bit output wires from the registers to MUX
                Qs4,Qs5,Qs6,Qs7,
                Qs8,Qs9,Qs10,Qs11,
                Qs12,Qs13,Qs14,Qs15,
                Qs16,Qs17,Qs18,Qs19,
                Qs20,Qs21,Qs22,Qs23,
                Qs24,Qs25,Qs26,Qs27,
                Qs28,Qs29,Qs30,Qs31;

    RF_DECODER5x32 BD1 (O,RW,LE);       // 5x32 Decoder to load enable the registers

    // 32-bit registers
    RF_REGISTER32 R0  (.Q(Qs0), .D(PW), .LE(O[0]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R1  (.Q(Qs1), .D(PW), .LE(O[1]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R2  (.Q(Qs2), .D(PW), .LE(O[2]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R3  (.Q(Qs3), .D(PW), .LE(O[3]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R4  (.Q(Qs4), .D(PW), .LE(O[4]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R5  (.Q(Qs5), .D(PW), .LE(O[5]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R6  (.Q(Qs6), .D(PW), .LE(O[6]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R7  (.Q(Qs7), .D(PW), .LE(O[7]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R8  (.Q(Qs8), .D(PW), .LE(O[8]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R9  (.Q(Qs9), .D(PW), .LE(O[9]),  .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R10 (.Q(Qs10),.D(PW), .LE(O[10]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R11 (.Q(Qs11),.D(PW), .LE(O[11]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R12 (.Q(Qs12),.D(PW), .LE(O[12]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R13 (.Q(Qs13),.D(PW), .LE(O[13]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R14 (.Q(Qs14),.D(PW), .LE(O[14]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R15 (.Q(Qs15),.D(PW), .LE(O[15]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R16 (.Q(Qs16),.D(PW), .LE(O[16]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R17 (.Q(Qs17),.D(PW), .LE(O[17]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R18 (.Q(Qs18),.D(PW), .LE(O[18]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R19 (.Q(Qs19),.D(PW), .LE(O[19]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R20 (.Q(Qs20),.D(PW), .LE(O[20]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R21 (.Q(Qs21),.D(PW), .LE(O[21]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R22 (.Q(Qs22),.D(PW), .LE(O[22]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R23 (.Q(Qs23),.D(PW), .LE(O[23]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R24 (.Q(Qs24),.D(PW), .LE(O[24]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R25 (.Q(Qs25),.D(PW), .LE(O[25]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R26 (.Q(Qs26),.D(PW), .LE(O[26]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R27 (.Q(Qs27),.D(PW), .LE(O[27]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R28 (.Q(Qs28),.D(PW), .LE(O[28]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R29 (.Q(Qs29),.D(PW), .LE(O[29]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R30 (.Q(Qs30),.D(PW), .LE(O[30]), .Clr(1'b0), .Clk(Clk));
    RF_REGISTER32 R31 (.Q(Qs31),.D(PW), .LE(O[31]), .Clr(1'b0), .Clk(Clk));

    // 32x1 MUX First register (R0) is always set to zero as manual dictates
    RF_MUX32x1 MUX_PA (PA, RA, 32'h0, 
                    Qs1,Qs2,Qs3,Qs4,Qs5,
                    Qs6,Qs7,Qs8,Qs9,Qs10,
                    Qs11,Qs12,Qs13,Qs14,Qs15,
                    Qs16,Qs17,Qs18,Qs19,Qs20,
                    Qs21,Qs22,Qs23,Qs24,Qs25,
                    Qs26,Qs27,Qs28,Qs29,Qs30,Qs31);

    // 32x1 MUX First register (R0) is always set to zero as manual dictates
    RF_MUX32x1 MUX_PB (PB, RB, 32'h0, 
                    Qs1,Qs2,Qs3,Qs4,Qs5,
                    Qs6,Qs7,Qs8,Qs9,Qs10,
                    Qs11,Qs12,Qs13,Qs14,Qs15,
                    Qs16,Qs17,Qs18,Qs19,Qs20,
                    Qs21,Qs22,Qs23,Qs24,Qs25,
                    Qs26,Qs27,Qs28,Qs29,Qs30,Qs31);
endmodule 


////////////////////////////// STAGES  //////////////////////////////////

module IF (
  input wire CLK, RST, LE,
  input wire S,
  input wire [7:0] TA,

  output wire [7:0]  address,
  output wire [31:0] instruction
);

    wire [7:0] B_PC;
    wire [7:0] back_q;
    wire [7:0] front_q;
    wire [7:0] next_pc;
    wire [7:0] jump_mux;
    
    PC_BACK_REGISTER back_reg (
        .Q(back_q),
        .D(next_pc),
        .LE(LE),
        .Rst(RST),
        .Clk(CLK)
    );

    MUX_IF pc_mux (
        .S(S),
        .TA(TA),
        .back(back_q),
        .O(jump_mux)
    );

    PC_FRONT_REGISTER front_reg (
        .Q(front_q),
        .D(jump_mux),
        .LE(LE),
        .Rst(RST),
        .Clk(CLK)
    );

    PC_ADDER pc_adder (
        .currPC(jump_mux),
        .nextPC(next_pc)
    );

    ROM instr_mem (
        .I(instruction),
        .A(front_q)
    );

    assign address = front_q;

endmodule

module ID (
    input wire CLK,
    input wire S,
    input wire R_LE,
    input wire [7:0]  address,
    input wire [31:0] instruction,
    
    input wire [4:0]  RD,
    input wire [31:0] PD_EX,
    input wire [31:0] PD_MEM,
    input wire [31:0] PD_WB,

    input wire [1:0]  A_S,
    input wire [1:0]  B_S,

    output wire [7:0] return_address,
    output wire [7:0] target_address,
    output wire [31:0] FPA,
    output wire [31:0] FPB,
    output wire [2:0]  COND,
    output wire [20:0] IM,
    output wire [4:0]  IDR,

    output wire [4:0] RA,
    output wire [4:0] RB,

    // Control unit signals
    output wire [1:0] PSW_LE_RE,       // 2-bit PSW Load / Read Enable
    output wire B,                     // Branch
    output wire [2:0] SOH_OP,          // 3-bit Operand handler opcode
    output wire [3:0] ALU_OP,          // 4-bit ALU opcode
    output wire [3:0] RAM_CTRL,        // 4-bit Ram control
    output wire L,                     // Select Dataout from RAM
    output wire RF_LE,                 // Register File Load Enable
    output wire [1:0] ID_SR,           // 2-bit Instruction Decode Shift Register
    output wire UB,                    // Unconditional Branch
    output wire NEG_COND               // Negate condition
);

  wire [4:0] RB_SHF_MUX;
  
  // From Control unit
  wire [1:0] CU_SRD;
  wire [1:0] CU_PSW_LE_RE;
  wire CU_B;
  wire [2:0] CU_SOH_OP;
  wire [3:0] CU_ALU_OP;
  wire [3:0] CU_RAM_CTRL;
  wire CU_L;
  wire CU_RF_LE;
  wire CU_UB;
  wire CU_SHF;
  wire CU_NEG_COND;
  
  // From Multiplexer of control unit
  wire MUX_SHF;

  wire [31:0] PA;
  wire [31:0] PB;

  CONTROL_UNIT control_unit (
      .instruction(instruction),
      .SRD(CU_SRD),             // Not pass to MUX
      .PSW_LE_RE(CU_PSW_LE_RE),  
      .B(CU_B),           
      .SOH_OP(CU_SOH_OP), 
      .ALU_OP(CU_ALU_OP),      
      .RAM_CTRL(CU_RAM_CTRL),  
      .L(CU_L),           
      .RF_LE(CU_RF_LE),   
      .ID_SR(ID_SR),           // Not pass to MUX
      .UB(CU_UB),
      .SHF(CU_SHF),
      .NEG_COND(CU_NEG_COND)
  );

  MUX_ID_IDR mux_id_idr (
      .S(CU_SRD),
      .I_0(instruction[4:0]),
      .I_1(instruction[25:21]),
      .I_2(instruction[20:16]),

      .IDR(IDR)
  );

  MUX_CU mux_cu (
      .S(S),

      .PSW_LE_RE_in(CU_PSW_LE_RE),
      .B_in(CU_B),
      .SOH_OP_in(CU_SOH_OP),
      .ALU_OP_in(CU_ALU_OP),
      .RAM_CTRL_in(CU_RAM_CTRL),
      .L_in(CU_L),
      .RF_LE_in(CU_RF_LE),
      .UB_in(CU_UB), 
      .SHF_in(CU_SHF), 
      .NEG_COND_in(CU_NEG_COND), 

      .PSW_LE_RE_out(PSW_LE_RE),
      .B_out(B),
      .SOH_OP_out(SOH_OP),
      .ALU_OP_out(ALU_OP),
      .RAM_CTRL_out(RAM_CTRL),
      .L_out(L),
      .RF_LE_out(RF_LE),
      .UB_out(UB),
      .SHF_out(MUX_SHF),
      .NEG_COND_out(NEG_COND)
  );

  MUX_ID_SHF mux_id_shf (
      .S(MUX_SHF),

      .RA(instruction[25:21]),
      .RB(instruction[20:16]),
      .O(RB_SHF_MUX)
  );

  TAG tag (
      .B_PC(address),           
      .offset(instruction[20:0]), 

      .TA(target_address),                
      .R(return_address)              
  );

  TP_REGISTER_FILE reg_file (
      .PA(PA), 
      .PB(PB), 

      .PW(PD_WB), 

      .RA(instruction[25:21]),
      .RB(RB_SHF_MUX),
      .RW(RD),

      .Clk(CLK),
      .LE(R_LE)
  );

  MUX_ID_FW_P fwpa (
      .S(A_S),

      .RP(PA),  
      .EX(PD_EX),  
      .MEM(PD_MEM), 
      .WB(PD_WB),  

      .FW_P(FPA)
  );

  MUX_ID_FW_P fwpb (
      .S(B_S),

      .RP(PB),  
      .EX(PD_EX),  
      .MEM(PD_MEM), 
      .WB(PD_WB),  

      .FW_P(FPB)
  );

  assign RA = instruction[25:21];
  assign RB = RB_SHF_MUX;
  assign IM = instruction[20:0];
  assign COND = instruction[15:13];

endmodule


module EX (
    input wire CLK,

    input wire [7:0] return_address,
    input wire [7:0] target_address,
    input wire [31:0] FPA,
    input wire [31:0] FPB,
    input wire [2:0]  COND,
    input wire [20:0] IM,
    input wire [4:0]  IDR,

    // Control unit signals
    input wire [1:0] PSW_LE_RE,      
    input wire B,                     
    input wire [2:0] SOH_OP,         
    input wire [3:0] ALU_OP,         
    input wire [3:0] RAM_CTRL,        
    input wire L,                    
    input wire RF_LE,                
    input wire UB,
    input wire NEG_COND,

    output wire EX_J,                   
    output wire [7:0] TARGET_ADDRESS,
    output wire [31:0] EX_OUT,                   
    output wire [31:0] EX_DI,                   
    output wire [4:0]  EX_RD,                   
    output wire EX_L,                   
    output wire EX_RF_LE, 
    output wire [3:0] RAM_CTRL_OUT,

    // For testing
    output wire CH_B,
    output wire CH_Odd,
    output wire CH_Z,
    output wire CH_N,
    output wire CH_C,
    output wire CH_V,
    output wire [2:0] CH_Cond,
    output wire CH_J
);
    assign EX_L = L;
    assign EX_RF_LE = RF_LE;
    assign EX_DI = FPB;
    assign EX_RD = IDR;
    assign TARGET_ADDRESS = target_address;
    assign RAM_CTRL_OUT = RAM_CTRL;

    wire [31:0] SOH_OUT;
    wire [31:0] ALU_OUT;
    wire Ci;

    wire Z;
    wire N; 
    wire C;
    wire V;

    wire J;

    OperandHandler op (
        .RB(FPB),
        .I(IM),   
        .S(SOH_OP),   
        .N(SOH_OUT) 
    );

    ALU alu (
        .A(FPA),         
        .B(SOH_OUT),         
        .Ci(Ci),         
        .OP(ALU_OP),         
        .Out(ALU_OUT),
        .Z(Z),
        .N(N), 
        .C(C),
        .V(V)     
    );

    CH cu (
        .NEG_COND(NEG_COND),
        .B(B),   
        .Odd(ALU_OUT[0]), 
        .Z(Z), 
        .N(N), 
        .C(C), 
        .V(V),   
        .Cond(COND),
        .J(J)      
    );

    PSW_REG psw (
        .clk(CLK),   
        .LE(PSW_LE_RE[0]),    
        .RE(PSW_LE_RE[1]),    
        .C_in(C),  
        .C_out(Ci)
    );

    MUX_EX_J mux_ex_j (
        .S(UB), 
        .J(J),  
        .O(EX_J)  
    );

    MUX_EX_RETURN_ADDRESS mux_ret(
        .S(UB),      
        .R(return_address),   
        .ALU(ALU_OUT), 
        .O(EX_OUT)
    );


  assign CH_B = B;
  assign CH_Odd = ALU_OUT[0];
  assign CH_Z = Z;
  assign CH_N = N;
  assign CH_C = C;
  assign CH_V = V;
  assign CH_Cond = COND;
  assign CH_J = J;
endmodule

module MEM (
    input wire [31:0] EX_OUT,                   
    input wire [31:0] EX_DI,                   
    input wire [4:0]  EX_RD, 
    input wire L,
    input wire EX_RF_LE, 
    input wire [3:0]  RAM_CTRL,        

    output wire [4:0]  MEM_RD, 
    output wire [31:0] MEM_OUT,
    output wire MEM_RF_LE 
);

    wire [31:0] DO; 

    RAM256x8 ram (
        .DataOut(DO), 
        .Enable(RAM_CTRL[0]),  
        .ReadWrite(RAM_CTRL[1]),
        .Address(EX_OUT[7:0]),  
        .Size(RAM_CTRL[3:2]),     
        .DataIn(EX_DI)  
    );

    MUX_MEM mux_mem (
        .S(L),           
        .DO(DO),  
        .EX(EX_OUT),   
        .O(MEM_OUT) 
    );

    assign MEM_RF_LE = EX_RF_LE;
    assign MEM_RD = EX_RD;

endmodule


////////////////////////////// DHDU //////////////////////////////////

module DHDU (
  input wire [4:0] RA,     // Source register 1
  input wire [4:0] RB,     // Source register 2

  input wire [4:0] EX_RD,  // Destination register in EX stage
  input wire [4:0] MEM_RD, // Destination register in MEM stage
  input wire [4:0] WB_RD,  // Destination register in WB stage

  input wire EX_RF_LE,     // Destination register write enable signal in EX stage
  input wire MEM_RF_LE,    // Destination register write enable signal in MEM stage
  input wire WB_RF_LE,     // Destination register write enable signal in WB stage

  input wire [1:0] SR,     // Selected operand register (RA, RB)
  input wire EX_L,         // Forward hazard from execution phase 
  output reg NOP,          // Stall signal for pipeline
  output reg LE,           // Load enable signal for the ID stage 
  output reg [1:0] A_S,    // Forwarding control for RA
  output reg [1:0] B_S     // Forwarding control for RB
);

  // Forwarding logic
  always @(*) begin
    // Default. No hazard detected 
    A_S = 2'b00;
    B_S = 2'b00;

    // Under normal conditions
    NOP = 1'b0;
    LE = 1'b1; 

    if (EX_L && ((SR[0] == 1 && (RA == EX_RD)) || (SR[1] == 1 && (RB == EX_RD)))) begin
      LE = 0; // Disable load enable signal
      NOP = 1; // Set NOP signal to indicate hazard
    end else begin

      // Criteria for Hazard Detection for Source Register RA
      if (SR[0] == 1) begin
        if (EX_RF_LE && (RA == EX_RD)) begin
          A_S = 2'b01; // Forward from EX stage
        end else if (MEM_RF_LE && (RA == MEM_RD)) begin
          A_S = 2'b10; // Forward from MEM stage
        end else if (WB_RF_LE && (RA == WB_RD)) begin
          A_S = 2'b11; // Forward from WB stage
        end else begin
          A_S = 2'b00; // No forwarding
        end
      end

      // Criteria for Hazard Detection for Source Register RB
      if (SR[1] == 1) begin
        if (EX_RF_LE && (RB == EX_RD)) begin
          B_S = 2'b01; // Forward from EX stage
        end else if (MEM_RF_LE && (RB == MEM_RD)) begin
          B_S = 2'b10; // Forward from MEM stage
        end else if (WB_RF_LE && (RB == WB_RD)) begin
          B_S = 2'b11; // Forward from WB stage
        end else begin
          B_S = 2'b00; // No forwarding
        end
      end
    end
  end
endmodule

////////////////////////////// CPU PIPELINE //////////////////////////////////

module CPU_PIPELINE (
    input wire CLK, RST
);

    // DHDU signals
    wire LE;
    wire NOP;
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] ID_SR;
    wire [4:0] RA;
    wire [4:0] RB;
    wire WB_RF_LE; 
    wire [4:0]  WB_RD;

    // Forwarding signals
    wire [31:0] EX_OUT;
    wire [31:0] MEM_OUT;
    wire [31:0] WB_OUT;

    //
    // FETCH STAGE
    //
    wire J;
    wire [7:0] TA;
    wire [7:0] B_PC;
    wire [7:0] front_q;
    wire [31:0] instruction;
    wire [31:0] fetched_instruction;

    IF if_stage (
        .CLK(CLK), .RST(RST), .LE(LE),
        .S(J),
        .TA(TA),
        .address(front_q),
        .instruction(fetched_instruction)
    );

    IF_ID_REGISTER if_id_reg (
        .LE(LE),
        .Rst(RST),
        .CLR(J),
        .Clk(CLK),

        .front_address(front_q),
        .fetched_instruction(fetched_instruction),

        .B_PC(B_PC),
        .instruction(instruction)
    );

    // 
    // DECODE STAGE
    // 

    wire [7:0]  ID_TA;
    wire [7:0]  ID_RET_ADDRESS;
    wire [31:0] ID_FPA;
    wire [31:0] ID_FPB;
    wire [2:0]  ID_COND;
    wire [20:0] ID_IM;
    wire [4:0]  ID_IDR;
    wire [1:0]  ID_PSW_LE_RE;      // 2-bit PSW Load / Read Enable
    wire ID_B;                     // Branch
    wire [2:0] ID_SOH_OP;          // 3-bit Operand handler opcode
    wire [3:0] ID_ALU_OP;          // 4-bit ALU opcode
    wire [3:0] ID_RAM_CTRL;        // 4-bit Ram control
    wire ID_L;                     // Select Dataout from RAM
    wire ID_RF_LE;                 // Register File Load Enable
    wire ID_UB; 
    wire ID_NEG_COND; 

    ID id_stage (
        .CLK(CLK),
        .S(NOP),
        .R_LE(WB_RF_LE),
        .address(B_PC),
        .instruction(instruction),

        .RD(WB_RD),
        .PD_EX(EX_OUT),
        .PD_MEM(MEM_OUT),
        .PD_WB(WB_OUT),
        
        .A_S(A_S),
        .B_S(B_S),

        .return_address(ID_RET_ADDRESS),
        .target_address(ID_TA),
        .FPA(ID_FPA),
        .FPB(ID_FPB),
        .COND(ID_COND),
        .IM(ID_IM),
        .IDR(ID_IDR),

        .RA(RA),
        .RB(RB),

        // Control unit signals
        .PSW_LE_RE(ID_PSW_LE_RE), 
        .B(ID_B),         
        .SOH_OP(ID_SOH_OP),    
        .ALU_OP(ID_ALU_OP),    
        .RAM_CTRL(ID_RAM_CTRL),  
        .L(ID_L),         
        .RF_LE(ID_RF_LE),     
        .ID_SR(ID_SR),     
        .UB(ID_UB),        
        .NEG_COND(ID_NEG_COND)        
    );

    //
    // Execution Stage
    //

    wire [7:0] EX_RET_ADDRESS;
    wire [7:0] EX_TA_ADDRESS;
    wire [31:0] EX_FPA;
    wire [31:0] EX_FPB;
    wire [2:0]  EX_COND;
    wire [20:0] EX_IM;
    wire [4:0]  EX_IDR;

    wire [1:0] EX_PSW_LE_RE;      
    wire EX_B;                     
    wire [2:0] EX_SOH_OP;         
    wire [3:0] EX_ALU_OP;         
    wire [3:0] EX_RAM_CTRL;        
    wire EX_L;                    
    wire EX_RF_LE;               
    wire EX_UB;
    wire EX_NEG_COND;

    // EX outputs
    wire [31:0] EX_DI;                   
    wire [4:0]  EX_RD;                   
    wire EX_MEM_L;                   
    wire EX_MEM_RF_LE; 
    wire [3:0] RAM_CTRL; 

    ID_EX_REG id_ex_reg (
        .clk(CLK),
        .reset(RST),

        // Register values and addresses
        .RA_in(ID_FPA),
        .RB_in(ID_FPB),
        .TA_in(ID_TA),
        .R_in(ID_RET_ADDRESS),

        // Condition and Immediate values
        .RD_in(ID_IDR),
        .COND_in(ID_COND),
        .IM_in(ID_IM),

        // Control signals from mux
        .PSW_LE_RE_in(ID_PSW_LE_RE),
        .B_in(ID_B),
        .SOH_OP_in(ID_SOH_OP),
        .ALU_OP_in(ID_ALU_OP),
        .RAM_CTRL_in(ID_RAM_CTRL),
        .L_in(ID_L),
        .RF_LE_in(ID_RF_LE),
        .UB_in(ID_UB),
        .NEG_COND_in(ID_NEG_COND),

        // Outputs Register values and addresses
        .RA_out(EX_FPA),
        .RB_out(EX_FPB),
        .TA_out(EX_TA_ADDRESS),
        .R_out(EX_RET_ADDRESS),

        // Outputs Condition and Immediate values
        .RD_out(EX_IDR),
        .COND_out(EX_COND),
        .IM_out(EX_IM),

        // Outputs to EX stage
        .PSW_LE_RE_out(EX_PSW_LE_RE),
        .B_out(EX_B),
        .SOH_OP_out(EX_SOH_OP),
        .ALU_OP_out(EX_ALU_OP),
        .RAM_CTRL_out(EX_RAM_CTRL),
        .L_out(EX_L),
        .RF_LE_out(EX_RF_LE),
        .UB_out(EX_UB),
        .NEG_COND_out(EX_NEG_COND)
    );

    EX ex_stage (
        .CLK(CLK),

        .return_address(EX_RET_ADDRESS),
        .target_address(EX_TA_ADDRESS),
        .FPA(EX_FPA),
        .FPB(EX_FPB),
        .COND(EX_COND),
        .IM(EX_IM),
        .IDR(EX_IDR),

        // Control unit signals
        .PSW_LE_RE(EX_PSW_LE_RE),      
        .B(EX_B),                     
        .SOH_OP(EX_SOH_OP),         
        .ALU_OP(EX_ALU_OP),         
        .RAM_CTRL(EX_RAM_CTRL),        
        .L(EX_L),                    
        .RF_LE(EX_RF_LE),                
        .UB(EX_UB),
        .NEG_COND(EX_NEG_COND),

        // Outputs
        .EX_J(J),                   
        .TARGET_ADDRESS(TA),
        .EX_OUT(EX_OUT),                   
        .EX_DI(EX_DI),                   
        .EX_RD(EX_RD),                   
        .EX_L(EX_MEM_L),                   
        .EX_RF_LE(EX_MEM_RF_LE), 
        .RAM_CTRL_OUT(RAM_CTRL) 
    );

    // 
    // Memory Stage
    // 
    wire [31:0] EX_OUT_IN;
    wire [31:0] EX_DI_IN;
    wire [4:0]  EX_RD_IN;

    wire L_IN;
    wire RF_LE_IN;
    wire [3:0] RAM_CTRL_IN;

    wire [4:0]  MEM_RD;
    wire MEM_RF_LE; 

    EX_MEM_REG ex_mem_reg (
        .clk(CLK),
        .reset(RST),

        .EX_OUT(EX_OUT),                   
        .EX_DI(EX_DI),                   
        .EX_RD(EX_RD), 
        .L(EX_MEM_L),
        .RF_LE(EX_MEM_RF_LE),
        .RAM_CTRL(RAM_CTRL),

        // Outputs
        .EX_OUT_IN(EX_OUT_IN),                   
        .EX_DI_IN(EX_DI_IN),                   
        .EX_RD_IN(EX_RD_IN), 
        .L_IN(L_IN),
        .RF_LE_IN(RF_LE_IN),
        .RAM_CTRL_IN(RAM_CTRL_IN)
    );

    MEM mem_stage (
        .EX_OUT(EX_OUT_IN),                   
        .EX_DI(EX_DI_IN),                   
        .EX_RD(EX_RD_IN), 
        .L(L_IN),
        .EX_RF_LE(RF_LE_IN), 
        .RAM_CTRL(RAM_CTRL_IN),        

        // Outputs
        .MEM_RD(MEM_RD), 
        .MEM_OUT(MEM_OUT),
        .MEM_RF_LE(MEM_RF_LE) 
    );

    //
    // WriteBack Stage
    //

    MEM_WB_REG mem_wb_reg (
        .clk(CLK),
        .reset(RST),

        .MEM_RD(MEM_RD),
        .MEM_OUT(MEM_OUT),
        .MEM_RF_LE(MEM_RF_LE),

        // Output
        .WB_RD(WB_RD),
        .WB_OUT(WB_OUT),
        .WB_RF_LE(WB_RF_LE)
    );

    //
    // Data hazzard detection unit handle
    //
    DHDU dhdu (
        .RA(RA),     
        .RB(RB),     

        .EX_RD(EX_RD),  
        .MEM_RD(MEM_RD), 
        .WB_RD(WB_RD),  

        .EX_RF_LE(EX_RF_LE),
        .MEM_RF_LE(MEM_RF_LE),
        .WB_RF_LE(WB_RF_LE),

        .SR(ID_SR),
        .EX_L(EX_MEM_L), 
        .NOP(NOP),
        .LE(LE),  
        .A_S(A_S),    
        .B_S(B_S)     
    );
endmodule


// Testbench for CPU_PIPELINE

module tb_CPU_PIPELINE;

    reg CLK = 0;
    reg RST = 1;

    CPU_PIPELINE uut (
        .CLK(CLK),
        .RST(RST)
    );

    // Clock: updates every 2 time units
    always #2 CLK = ~CLK;

    task dump_data_memory;
        integer i;
        begin
            $display("Memory content:");
            for (i = 0; i < 256; i = i + 4) begin
                $write("%b %b %b %b\n", 
                uut.mem_stage.ram.Mem[i], 
                uut.mem_stage.ram.Mem[i+1], 
                uut.mem_stage.ram.Mem[i+2], 
                uut.mem_stage.ram.Mem[i+3]);

                // $write("%b %b %b %b\n", 
                // uut.if_stage.instr_mem.Mem[i], 
                // uut.if_stage.instr_mem.Mem[i+1], 
                // uut.if_stage.instr_mem.Mem[i+2], 
                // uut.if_stage.instr_mem.Mem[i+3]);
            end
        end
    endtask

    initial begin
        $display("Starting simulation...");

        // Aplicar reset
        #3 RST = 0;

        // Wait for the simulation to finish
        #500 $display("Program finished.");

        dump_data_memory();
        $finish;
    end

    initial begin

        // $monitor("Front: %d | SRD: %b | PSW_LE_RE: %b | B: %b | SOH_OP: %b | ALU_OP: %b | RAM_CTRL: %b | L: %b | RF_LE: %b | ID_SR: %b | UB: %b | SHF: %b",
        //     uut.if_stage.front_q,
        //     uut.id_stage.control_unit.SRD,
        //     uut.id_stage.control_unit.PSW_LE_RE,
        //     uut.id_stage.control_unit.B,
        //     uut.id_stage.control_unit.SOH_OP,
        //     uut.id_stage.control_unit.ALU_OP,
        //     uut.id_stage.control_unit.RAM_CTRL,
        //     uut.id_stage.control_unit.L,
        //     uut.id_stage.control_unit.RF_LE,
        //     uut.id_stage.control_unit.ID_SR,
        //     uut.id_stage.control_unit.UB,
        //     uut.id_stage.control_unit.SHF
        // );
        
        // // Monitor for test #1 (Validation program)
        // $monitor("Front: %d | GR1: %d | GR2: %d | GR3: %d | GR5: %d",
        //     uut.if_stage.front_q,
        //     uut.id_stage.reg_file.R1.Q,
        //     uut.id_stage.reg_file.R2.Q,
        //     uut.id_stage.reg_file.R3.Q,
        //     uut.id_stage.reg_file.R5.Q
        // );

        // Monitor for test #2 (Validation program)
        // $monitor("Front: %d | GR1: %d | GR2: %d | GR3: %d | GR4: %d | GR5: %d | GR10: %d | GR11: %d | GR12: %d | GR14: %d",
        //     uut.if_stage.front_q,
        //     uut.id_stage.reg_file.R1.Q_S,
        //     uut.id_stage.reg_file.R2.Q_S,
        //     uut.id_stage.reg_file.R3.Q_S,
        //     uut.id_stage.reg_file.R4.Q_S,
        //     uut.id_stage.reg_file.R5.Q_S,
        //     uut.id_stage.reg_file.R10.Q_S,
        //     uut.id_stage.reg_file.R11.Q_S,
        //     uut.id_stage.reg_file.R12.Q_S,
        //     uut.id_stage.reg_file.R14.Q_S
        // );

        // Monitor for test #3 (Validation program)
        // $monitor("Front: %d | GR1: %d | GR2: %d | GR3: %d | GR5: %d | GR6: %d",
        //     uut.if_stage.front_q,
        //     uut.id_stage.reg_file.R1.Q,
        //     uut.id_stage.reg_file.R2.Q,
        //     uut.id_stage.reg_file.R3.Q,
        //     uut.id_stage.reg_file.R5.Q,
        //     uut.id_stage.reg_file.R6.Q
        // );


        // $monitor("Front: %d | DI %b | DO %b | EX_OUT %b | MEM_OUT %b",
        //     uut.if_stage.front_q, 
        //     uut.mem_stage.EX_DI, 
        //     uut.mem_stage.DO, 
        //     uut.mem_stage.EX_OUT, 
        //     uut.mem_stage.MEM_OUT
        // );

        // $monitor("Front: %d | WB_RD %b | WB_OUT %b | WB_RF_LE %b",
        //     uut.if_stage.front_q, 
        //     uut.WB_RD,
        //     uut.mem_stage.mux_mem.S,
        //     uut.WB_RF_LE
        // );

        // $monitor("Front: %d | R_LE %b | RD %b | PD_EX %b | PD_MEM %b | PD_WB %b",
        //     uut.if_stage.front_q, 
        //     uut.id_stage.R_LE,
        //     uut.id_stage.RD,
        //     uut.id_stage.PD_EX,
        //     uut.id_stage.PD_MEM,
        //     uut.id_stage.PD_WB
        // );

        // $monitor("Front: %d | RA %b | RB %b | EX_RD %b | MEM_RD %b | WB_RD %b | EX_RF_LE %b | MEM_RF_LE %b | WB_RF_LE %b | SR %b | EX_L %b | NOP %b | LE %b | A_S %b | B_S %b",
        //     uut.if_stage.front_q, 
        //     uut.dhdu.RA,
        //     uut.dhdu.RB,
        //     uut.dhdu.EX_RD,
        //     uut.dhdu.MEM_RD,
        //     uut.dhdu.WB_RD,
        //     uut.dhdu.EX_RF_LE,
        //     uut.dhdu.MEM_RF_LE,
        //     uut.dhdu.WB_RF_LE,
        //     uut.dhdu.SR,
        //     uut.dhdu.EX_L,
        //     uut.dhdu.NOP,
        //     uut.dhdu.LE,
        //     uut.dhdu.A_S,
        //     uut.dhdu.B_S
        // );

        // $monitor("Front: %d | TA %b | UB %b |B %b | ODD %b | Z %b | N %b | C %b | V %b | COND %b | J %b",
        //     uut.if_stage.front_q, 
        //     uut.ex_stage.TARGET_ADDRESS,
        //     uut.ex_stage.UB,
        //     uut.ex_stage.CH_B,
        //     uut.ex_stage.CH_Odd,
        //     uut.ex_stage.CH_Z,
        //     uut.ex_stage.CH_N,
        //     uut.ex_stage.CH_C,
        //     uut.ex_stage.CH_V,
        //     uut.ex_stage.CH_Cond,
        //     uut.ex_stage.CH_J
        // );

        $monitor("Front: %d | FPA %b | FPB %b | EX_RD %b | EX_OUT %b | EX_DI %b | SOH_OP %b | ALU_OP %b",
            uut.if_stage.front_q, 
            uut.ex_stage.FPA,
            uut.ex_stage.FPB,
            uut.ex_stage.EX_RD,
            uut.ex_stage.EX_OUT,
            uut.ex_stage.EX_DI,
            uut.ex_stage.SOH_OP,
            uut.ex_stage.ALU_OP
        );
    end

endmodule
