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
    RF_REGISTER32 R0  (Qs0, PW, O[0],  1'b0, Clk);
    RF_REGISTER32 R1  (Qs1, PW, O[1],  1'b0, Clk);
    RF_REGISTER32 R2  (Qs2, PW, O[2],  1'b0, Clk);
    RF_REGISTER32 R3  (Qs3, PW, O[3],  1'b0, Clk);
    RF_REGISTER32 R4  (Qs4, PW, O[4],  1'b0, Clk);
    RF_REGISTER32 R5  (Qs5, PW, O[5],  1'b0, Clk);
    RF_REGISTER32 R6  (Qs6, PW, O[6],  1'b0, Clk);
    RF_REGISTER32 R7  (Qs7, PW, O[7],  1'b0, Clk);
    RF_REGISTER32 R8  (Qs8, PW, O[8],  1'b0, Clk);
    RF_REGISTER32 R9  (Qs9, PW, O[9],  1'b0, Clk);
    RF_REGISTER32 R10 (Qs10,PW, O[10], 1'b0, Clk);
    RF_REGISTER32 R11 (Qs11,PW, O[11], 1'b0, Clk);
    RF_REGISTER32 R12 (Qs12,PW, O[12], 1'b0, Clk);
    RF_REGISTER32 R13 (Qs13,PW, O[13], 1'b0, Clk);
    RF_REGISTER32 R14 (Qs14,PW, O[14], 1'b0, Clk);
    RF_REGISTER32 R15 (Qs15,PW, O[15], 1'b0, Clk);
    RF_REGISTER32 R16 (Qs16,PW, O[16], 1'b0, Clk);
    RF_REGISTER32 R17 (Qs17,PW, O[17], 1'b0, Clk);
    RF_REGISTER32 R18 (Qs18,PW, O[18], 1'b0, Clk);
    RF_REGISTER32 R19 (Qs19,PW, O[19], 1'b0, Clk);
    RF_REGISTER32 R20 (Qs20,PW, O[20], 1'b0, Clk);
    RF_REGISTER32 R21 (Qs21,PW, O[21], 1'b0, Clk);
    RF_REGISTER32 R22 (Qs22,PW, O[22], 1'b0, Clk);
    RF_REGISTER32 R23 (Qs23,PW, O[23], 1'b0, Clk);
    RF_REGISTER32 R24 (Qs24,PW, O[24], 1'b0, Clk);
    RF_REGISTER32 R25 (Qs25,PW, O[25], 1'b0, Clk);
    RF_REGISTER32 R26 (Qs26,PW, O[26], 1'b0, Clk);
    RF_REGISTER32 R27 (Qs27,PW, O[27], 1'b0, Clk);
    RF_REGISTER32 R28 (Qs28,PW, O[28], 1'b0, Clk);
    RF_REGISTER32 R29 (Qs29,PW, O[29], 1'b0, Clk);
    RF_REGISTER32 R30 (Qs30,PW, O[30], 1'b0, Clk);
    RF_REGISTER32 R31 (Qs31,PW, O[31], 1'b0, Clk);

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
