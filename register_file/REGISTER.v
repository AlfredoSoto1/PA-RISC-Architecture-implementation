module Register32(output reg [31:0] Q, input wire [31:0] D, input wire LE, Clr, Clk);
    always @(posedge Clk) begin
        if (Clr) 
            Q <= 32'h00000000;  // Reset the register to 0
        else if (LE) 
            Q <= D;  // Store new value if LE is high
    end
endmodule
