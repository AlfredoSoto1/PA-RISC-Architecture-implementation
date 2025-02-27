module Register32_TEST;
    reg [31:0] D; 
    reg LE, Clr, Clk;
    wire [31:0] Q;
    
    // Instantiate the Register32 module
    Register32 uut (
        .Q(Q),
        .D(D),
        .LE(LE),
        .Clr(Clr),
        .Clk(Clk)
    );

    // Clock generation: Toggle every 5 units of time
    always #5 Clk = ~Clk;

    initial begin
        Clk = 0;
        Clr = 1; LE = 0; D = 32'h00000000;
        #10;

        // Test 1: Clear the register
        Clr = 1; LE = 1; D = 32'hA5A5A5A5; // Load some value
        #10;
        $display("Test 1 - Clear: Q = %h (Expected: 00000000)", Q);
        
        // Test 2: Load a new value
        Clr = 0; LE = 1; D = 32'hDEADBEEF;
        #10;
        $display("Test 2 - Load: Q = %h (Expected: DEADBEEF)", Q);

        // Test 3: Keep value when LE = 0
        LE = 0; D = 32'hCAFEBABE;
        #10;
        $display("Test 3 - Hold Value: Q = %h (Expected: DEADBEEF)", Q);

        // Test 4: Clear the register again
        Clr = 1;
        #10;
        $display("Test 4 - Clear Again: Q = %h (Expected: 00000000)", Q);

        // Test 5: Load another value
        Clr = 0; LE = 1; D = 32'h12345678;
        #10;
        $display("Test 5 - Load New: Q = %h (Expected: 12345678)", Q);
        $stop;
    end
endmodule
