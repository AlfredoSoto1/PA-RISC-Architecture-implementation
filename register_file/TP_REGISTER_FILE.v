`include "MUX.v" 
`include "DECODER.v"
`include "REGISTER.v" 

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

    DECODER5x32 BD1 (O,RW,LE);       // 5x32 Decoder to load enable the registers

    // 32-bit registers
    REGISTER32 R0  (Qs0, PW, O[0],  1'b0, Clk);
    REGISTER32 R1  (Qs1, PW, O[1],  1'b0, Clk);
    REGISTER32 R2  (Qs2, PW, O[2],  1'b0, Clk);
    REGISTER32 R3  (Qs3, PW, O[3],  1'b0, Clk);
    REGISTER32 R4  (Qs4, PW, O[4],  1'b0, Clk);
    REGISTER32 R5  (Qs5, PW, O[5],  1'b0, Clk);
    REGISTER32 R6  (Qs6, PW, O[6],  1'b0, Clk);
    REGISTER32 R7  (Qs7, PW, O[7],  1'b0, Clk);
    REGISTER32 R8  (Qs8, PW, O[8],  1'b0, Clk);
    REGISTER32 R9  (Qs9, PW, O[9],  1'b0, Clk);
    REGISTER32 R10 (Qs10,PW, O[10], 1'b0, Clk);
    REGISTER32 R11 (Qs11,PW, O[11], 1'b0, Clk);
    REGISTER32 R12 (Qs12,PW, O[12], 1'b0, Clk);
    REGISTER32 R13 (Qs13,PW, O[13], 1'b0, Clk);
    REGISTER32 R14 (Qs14,PW, O[14], 1'b0, Clk);
    REGISTER32 R15 (Qs15,PW, O[15], 1'b0, Clk);
    REGISTER32 R16 (Qs16,PW, O[16], 1'b0, Clk);
    REGISTER32 R17 (Qs17,PW, O[17], 1'b0, Clk);
    REGISTER32 R18 (Qs18,PW, O[18], 1'b0, Clk);
    REGISTER32 R19 (Qs19,PW, O[19], 1'b0, Clk);
    REGISTER32 R20 (Qs20,PW, O[20], 1'b0, Clk);
    REGISTER32 R21 (Qs21,PW, O[21], 1'b0, Clk);
    REGISTER32 R22 (Qs22,PW, O[22], 1'b0, Clk);
    REGISTER32 R23 (Qs23,PW, O[23], 1'b0, Clk);
    REGISTER32 R24 (Qs24,PW, O[24], 1'b0, Clk);
    REGISTER32 R25 (Qs25,PW, O[25], 1'b0, Clk);
    REGISTER32 R26 (Qs26,PW, O[26], 1'b0, Clk);
    REGISTER32 R27 (Qs27,PW, O[27], 1'b0, Clk);
    REGISTER32 R28 (Qs28,PW, O[28], 1'b0, Clk);
    REGISTER32 R29 (Qs29,PW, O[29], 1'b0, Clk);
    REGISTER32 R30 (Qs30,PW, O[30], 1'b0, Clk);
    REGISTER32 R31 (Qs31,PW, O[31], 1'b0, Clk);

    // 32x1 MUX First register (R0) is always set to zero as manual dictates
    MUX32x1 MUX_PA (PA, RA, 32'h0, 
                    Qs1,Qs2,Qs3,Qs4,Qs5,
                    Qs6,Qs7,Qs8,Qs9,Qs10,
                    Qs11,Qs12,Qs13,Qs14,Qs15,
                    Qs16,Qs17,Qs18,Qs19,Qs20,
                    Qs21,Qs22,Qs23,Qs24,Qs25,
                    Qs26,Qs27,Qs28,Qs29,Qs30,Qs31);

    // 32x1 MUX First register (R0) is always set to zero as manual dictates
    MUX32x1 MUX_PB (PB, RB, 32'h0, 
                    Qs1,Qs2,Qs3,Qs4,Qs5,
                    Qs6,Qs7,Qs8,Qs9,Qs10,
                    Qs11,Qs12,Qs13,Qs14,Qs15,
                    Qs16,Qs17,Qs18,Qs19,Qs20,
                    Qs21,Qs22,Qs23,Qs24,Qs25,
                    Qs26,Qs27,Qs28,Qs29,Qs30,Qs31); 
endmodule 
