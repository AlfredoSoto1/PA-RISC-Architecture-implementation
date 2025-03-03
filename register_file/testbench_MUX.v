`include "MUX.v"

module MUX32x1_tb;
    wire [31:0] P;           // Output of MUX
    reg [4:0] S;             // 5-bit selection input
    reg [31:0] R0, R1, R2, R3, R4, R5, R6, R7, 
               R8, R9, R10, R11, R12, R13, R14, R15,
               R16, R17, R18, R19, R20, R21, R22, R23,
               R24, R25, R26, R27, R28, R29, R30, R31;

    // Instantiate the MUX32x1 module
    MUX32x1 mux (
        .P(P),
        .S(S),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3),
        .R4(R4), .R5(R5), .R6(R6), .R7(R7), 
        .R8(R8), .R9(R9), .R10(R10), .R11(R11),
        .R12(R12), .R13(R13), .R14(R14), .R15(R15),
        .R16(R16), .R17(R17), .R18(R18), .R19(R19),
        .R20(R20), .R21(R21), .R22(R22), .R23(R23),
        .R24(R24), .R25(R25), .R26(R26), .R27(R27),
        .R28(R28), .R29(R29), .R30(R30), .R31(R31)
    );

    initial begin
        // Assign test values to inputs
        R0 = 32'h00000001; R1 = 32'h00000002; R2 = 32'h00000003; R3 = 32'h00000004;
        R4 = 32'h00000005; R5 = 32'h00000006; R6 = 32'h00000007; R7 = 32'h00000008;
        R8 = 32'h00000009; R9 = 32'h0000000A; R10 = 32'h0000000B; R11 = 32'h0000000C;
        R12 = 32'h0000000D; R13 = 32'h0000000E; R14 = 32'h0000000F; R15 = 32'h00000010;
        R16 = 32'h00000011; R17 = 32'h00000012; R18 = 32'h00000013; R19 = 32'h00000014;
        R20 = 32'h00000015; R21 = 32'h00000016; R22 = 32'h00000017; R23 = 32'h00000018;
        R24 = 32'h00000019; R25 = 32'h0000001A; R26 = 32'h0000001B; R27 = 32'h0000001C;
        R28 = 32'h0000001D; R29 = 32'h0000001E; R30 = 32'h0000001F; R31 = 32'h00000020;

        // Test different selections
        $display("Testing MUX32x1...");

        S = 5'd0;  #10; $display("S=%d, P=%h (Expected: 00000001)", S, P);
        S = 5'd1;  #10; $display("S=%d, P=%h (Expected: 00000002)", S, P);
        S = 5'd5;  #10; $display("S=%d, P=%h (Expected: 00000006)", S, P);
        S = 5'd10; #10; $display("S=%d, P=%h (Expected: 0000000B)", S, P);
        S = 5'd15; #10; $display("S=%d, P=%h (Expected: 00000010)", S, P);
        S = 5'd20; #10; $display("S=%d, P=%h (Expected: 00000015)", S, P);
        S = 5'd31; #10; $display("S=%d, P=%h (Expected: 00000020)", S, P);

        $finish; // Stop simulation
    end
endmodule
