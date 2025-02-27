module MultiPlexer32to1_TEST;
    reg [4:0] S;            // 5-bit selection input
    reg [31:0] I [31:0];    // 32 inputs, each 32-bit wide
    wire [31:0] P;          // Output of MUX

    // Instantiate the MUX32to1 module
    MUX32to1 uut (
        .S(S),
        .I(I),
        .P(P)
    );

    initial begin
        // Initialize the inputs with some values
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            I[i] = i * 10; // Assign each input a multiple of 10 (e.g., 0, 10, 20, ..., 310)
        end
        
        // Test different selection values
        $monitor("Time=%0t | S=%d | Y=%d", $time, S, Y);
        
        #10 S = 5'b00000;  // Select I[0]  -> Expected P = 0
        #10 S = 5'b00001;  // Select I[1]  -> Expected P = 10
        #10 S = 5'b00010;  // Select I[2]  -> Expected P = 20
        #10 S = 5'b00100;  // Select I[4]  -> Expected P = 40
        #10 S = 5'b01000;  // Select I[8]  -> Expected P = 80
        #10 S = 5'b10000;  // Select I[16] -> Expected P = 160
        #10 S = 5'b11111;  // Select I[31] -> Expected P = 310
        
        #10 $finish; // End simulation
    end
endmodule