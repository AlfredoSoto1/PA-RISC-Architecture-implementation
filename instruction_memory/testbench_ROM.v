`include "ROM.v"

module ROM_tb; 
    // Module variables
    reg [7:0] A;   // Address
    wire [31:0] I; // Instruction

    // ROM module instance
    rom256x8 rom1 (
        .I(I), 
        .A(A)
    );

    initial begin
        // Leer instrucciones en direcciones 0, 4, 8 y 12
        $display("Reading instructions from memory location 0, 4, 8, 12:");
        A = 8'd0;  #1 $display("A = %d, I = %h", A, I);
        A = 8'd4;  #1 $display("A = %d, I = %h", A, I);
        A = 8'd8;  #1 $display("A = %d, I = %h", A, I);
        A = 8'd12; #1 $display("A = %d, I = %h", A, I);

        $finish;
    end

endmodule
