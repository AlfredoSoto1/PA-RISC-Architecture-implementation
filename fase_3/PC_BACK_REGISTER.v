module PC_BACK_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'd4;       // Initialize to 4 on reset
        else if (LE)
            Q <= D;          // Load new value if enabled
    end
endmodule
