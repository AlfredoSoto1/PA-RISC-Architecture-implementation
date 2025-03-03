`include "DECODER.v"

module DECODER_tb;
    reg [4:0] D;
    reg E;
    wire [31:0] O;

    // Instantiate the binaryDecoder module
    DECODER5x32 decoder (
        .O(O),
        .D(D),
        .E(E)
    );

    initial begin
        $monitor("E = %b, D = %b, O = %b", E, D, O);

        // Test case 1: Enable is 0, output should be 0
        E = 0; D = 5'b00000; #10;
        E = 0; D = 5'b10101; #10;

        // Test case 2: Enable is 1, different values of D
        E = 1; D = 5'b00000; #10;
        E = 1; D = 5'b00001; #10;
        E = 1; D = 5'b00010; #10;
        E = 1; D = 5'b01111; #10;
        E = 1; D = 5'b10101; #10;
        E = 1; D = 5'b11111; #10;

        // Test case 3: Changing enable mid-operation
        E = 1; D = 5'b01010; #10;
        E = 0; #10;

        // Test case 4: Invalid values (not necessary for 5-bit input, but added for completeness)
        D = 5'bxxxxx; #10;
        $finish;
    end
endmodule

