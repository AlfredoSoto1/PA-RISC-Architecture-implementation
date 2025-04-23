module PSW (
  input wire clk,          // Clock signal
  input wire LE,           // Load enable signal
  input wire RE,           // Read enable signal
  input wire data_in,      // Data input (1-bit wide, C/B)
  output wire data_out     // Data output (1-bit wide, C/B)
);

  reg register; // Internal register to store 1-bit data

  // Load data into the register on the rising edge of the clock
  always @(posedge clk) begin
    if (LE) begin
      register <= data_in;
    end
  end

  // Output data only when read enable is high
  assign data_out = RE ? register : 1'bz;

endmodule