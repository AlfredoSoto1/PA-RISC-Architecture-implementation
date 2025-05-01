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
