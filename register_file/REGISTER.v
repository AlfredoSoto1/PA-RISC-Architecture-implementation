module REGISTER32 (
    output reg [31:0] Q,     // 32-bit output 
    input wire [31:0] D,     // 32-bit input
    input wire LE, Clr, Clk  // Load enable, clear, clock
);
    always @(posedge Clk) begin
        if (Clr) 
            // If clear is high, reset the register to 0
            Q <= 32'h00000000;
        else if (LE) 
            // If load enable is high, store the input value
            Q <= D;
    end
endmodule
