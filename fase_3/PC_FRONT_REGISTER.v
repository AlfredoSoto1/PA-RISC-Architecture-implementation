module PC_FRONT_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'h00;      // Synchronous reset to 0
        else if (LE)
            Q <= D;          // Load input value if LE is high
    end
endmodule
