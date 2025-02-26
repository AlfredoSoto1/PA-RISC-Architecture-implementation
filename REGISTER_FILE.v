'include "decoder.v"
'include "mux.v" 
'include "register.v" 

module RegisterFile (output [31:0] PA, PB, input [31:0] PW, input [4:0] RA, RB, RW, input Clk, LE);

    wire [31:0] Qs0,Qs1,Qs2,Qs3,Qs4,Qs5,Qs6,Qs7,Qs8,Qs9,Qs10,Qs11,Qs12,Qs13,Qs14,Qs15,Qs16,Qs17,Qs18,Qs19,Qs20,Qs21,Qs22,Qs23,Qs24,Qs25,Qs26,Qs27,Qs28,Qs29,Qs30,Qs31;
    
    wire [31:0] O;

    //Declarar modulos individuales 31:0
    binaryDecoder BD1 (O,RW,LE);

    register32 R0 (Qs0,Clk,O[0] ,PW);
    register32 R1 (Qs1,Clk,O[1] ,PW);
    register32 R2 (Qs2,Clk,O[2] ,PW);
    register32 R3 (Qs3,Clk,O[3] ,PW);
    register32 R4 (Qs4,Clk,O[4] ,PW);
    register32 R5 (Qs5,Clk,O[5] ,PW);
    register32 R6 (Qs6,Clk,O[6] ,PW);
    register32 R7 (Qs7,Clk,O[7] ,PW);
    register32 R8 (Qs8,Clk,O[8] ,PW);
    register32 R9 (Qs9,Clk,O[9] ,PW);
    register32 R10 (Qs10,Clk,O[10] ,PW);
    register32 R11 (Qs11,Clk,O[11] ,PW);
    register32 R12 (Qs12,Clk,O[12] ,PW);
    register32 R13 (Qs13,Clk,O[13] ,PW);
    register32 R14 (Qs14,Clk,O[14] ,PW);
    register32 R15 (Qs15,Clk,O[15] ,PW);
    register32 R16 (Qs16,Clk,O[16] ,PW);
    register32 R17 (Qs17,Clk,O[17] ,PW);
    register32 R18 (Qs18,Clk,O[18] ,PW);
    register32 R19 (Qs19,Clk,O[19] ,PW);
    register32 R20 (Qs20,Clk,O[20] ,PW);
    register32 R21 (Qs21,Clk,O[21] ,PW);
    register32 R22 (Qs22,Clk,O[22] ,PW);
    register32 R23 (Qs23,Clk,O[23] ,PW);
    register32 R24 (Qs24,Clk,O[24] ,PW);
    register32 R25 (Qs25,Clk,O[25] ,PW);
    register32 R26 (Qs26,Clk,O[26] ,PW);
    register32 R27 (Qs27,Clk,O[27] ,PW);
    register32 R28 (Qs28,Clk,O[28] ,PW);
    register32 R29 (Qs29,Clk,O[29] ,PW);
    register32 R30 (Qs30,Clk,O[30] ,PW);
    register32 R31 (Qs31,Clk,O[31] ,PW);

    multiPlexer mpPA (PA, 32'h00000000,Qs1,Qs2,Qs3,Qs4,Qs5,Qs6,Qs7,Qs8,Qs9,Qs10,Qs11,Qs12,Qs13,Qs14,Qs15,
        Qs16,Qs17,Qs18,Qs19,Qs20,Qs21,Qs22,Qs23,Qs24,Qs25,Qs26,Qs27,Qs28,Qs29,Qs30,Qs31, RA);
    multiPlexer mpPB (PB, 32'h00000000,Qs1,Qs2,Qs3,Qs4,Qs5,Qs6,Qs7,Qs8,Qs9,Qs10,Qs11,Qs12,Qs13,Qs14,Qs15,
        Qs16,Qs17,Qs18,Qs19,Qs20,Qs21,Qs22,Qs23,Qs24,Qs25,Qs26,Qs27,Qs28,Qs29,Qs30,Qs31, RB);

endmodule 
