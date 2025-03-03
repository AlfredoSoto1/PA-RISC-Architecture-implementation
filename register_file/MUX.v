module MUX32x1 (
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