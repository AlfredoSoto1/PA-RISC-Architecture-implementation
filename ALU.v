
module ALU (
    input [31:0] A,         // 32-bit register
    input [31:0] B,         // 32-bit register
    input Ci,               // Carry bit
    input [3:0] OP,         // OP-Code
    output reg [31:0] Out,  // 32-bit register
    output reg Z, N, C, V   // 4-bit flag register
);

    reg [32:0] temp; // Temporary register to store extended sum for carry

    always @(*) begin
        case (OP)
            4'b0000: temp = A + B;       // (With flags) Addition
            4'b0001: temp = A + B + Ci;  // (With flags) Addition with carry
            4'b0010: temp = A - B;       // (With flags) Subtraction
            4'b0011: temp = A - B - Ci;  // (With flags) Subtraction with carry
            4'b0100: Out = B - A;        // Subtraction flipped
            4'b0101: Out = A | B;        // OR
            4'b0110: Out = A ^ B;        // XOR
            4'b0111: Out = A & B;        // AND
            4'b1000: Out = A;            // Pass A
            4'b1001: Out = A + 8;        // Shift A 8 places forward
            4'b1010: Out = B;            // Pass B
            default: Out = 32'h00000000; // Default case
        endcase
        
        // Provide result for the first 4 OP-code
        if (OP == 4'b0000 || OP == 4'b0001 || OP == 4'b0010 || OP == 4'b0011) begin
            Out = temp[31:0];                          // Pass out the operation result
            C = temp[32];                              // Carry/Borrow for unsigned numbers
            V = (OP == 4'b0000 || OP == 4'b0001) ?     // Overflow bit for sign numbers
                ~(A[31] ^ B[31]) & (A[31] ^ Out[31]) : // Overflow for sum
                 (A[31] ^ B[31]) & (A[31] ^ Out[31]);  // Overflow for sub
        end

        Z = (Out == 32'h00000000) ? 1 : 0; // Zero flag
        N = Out[31];                       // Sign flag
    end
endmodule


module ALU_TEST;
    reg [31:0] A, B;
    reg Ci;
    reg [3:0] OP;
    wire [31:0] Out;
    wire Z, N, C, V;

    ALU uut (
        .A(A),
        .B(B),
        .Ci(Ci),
        .OP(OP),
        .Out(Out),
        .Z(Z),
        .N(N),
        .C(C),
        .V(V)
    );

    initial begin
        $display("A = 10011100000000000000000000111000");
        $display("B = 01110000000000000000000000000011");
        $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        $display("| Time |  OP  |       A      |               A(bin)             |       B      |               B(bin)             |      Out     |           Out(bin)               | Z | N | C | V |");
        $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        
        A = 32'b10011100000000000000000000111000;
        B = 32'b01110000000000000000000000000011;
        Ci = 0;
        OP = 4'b0000;

        // Increment OP every 2 time units
        repeat (10) begin
            #2 OP = OP + 1;
        end

        $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
        $display("| Time |  OP  |       A      |               A(bin)             |       B      |               B(bin)             |      Out     |           Out(bin)               | Z | N | C | V |");
        $display("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

        Ci = 1;
        OP = 4'b0000;
        repeat (3) begin
            #2 OP = OP + 1;
        end
        
        #2 $finish;
    end
    
    initial begin
        $monitor("| %4t | %b | %12d | %b | %12d | %b | %12d | %b | %b | %b | %b | %b |", 
                 $time, OP, A, A, B, B, Out, Out, Z, N, C, V);
    end
endmodule