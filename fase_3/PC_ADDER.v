module PC_ADDER (
    input [7:0] currPC, // Current Program Counter
    output [7:0] nextPC // Next Program Counter
);
    assign nextPC = currPC + 4; // Add 4 to the current PC
endmodule