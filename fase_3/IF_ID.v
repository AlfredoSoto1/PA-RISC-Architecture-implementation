module IF_ID_REGISTER (
    output reg [31:0] Q,     // 32-bit output 
    input wire [31:0] D,     // 32-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 32'h0;      // Synchronous reset to 0
        else if (LE)
            Q <= D;          // Load input value if LE is high
    end
endmodule
