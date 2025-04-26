module OperandHandler (
    input  wire [31:0] RB,  // RB: 32-bit (register)
    input  wire [20:0] I,   // I (input)
    input  wire [2:0] S,    // S (select)
    output reg  [31:0] N    // N (out)
);
    wire [4:0] shift_amt;         // Shift amount (31 - I[9:5])
    wire [31:0] low_sign_ext_11;  // Sign-extended I[10:0]
    wire [31:0] low_sign_ext_14;  // Sign-extended I[13:0]
    wire [31:0] shift_right_logic;
    wire [31:0] shift_right_arith;
    wire [31:0] shift_left_logic;

    assign low_sign_ext_11 = {{22{I[0]}}, I[10:1]};        // Sign-extend I[10:0] to 32 bits
    assign low_sign_ext_14 = {{19{I[0]}}, I[13:1]};        // Sign-extend I[13:0] to 32 bits
    
    assign shift_amt = 31 - I[9:5];
    assign shift_right_logic = RB >> shift_amt;            // Logical shift right
    assign shift_right_arith = $signed(RB) >>> shift_amt;  // Arithmetic shift right (sign extended)
    assign shift_left_logic  = RB << shift_amt;            // Logical shift left

    always @* begin
        case (S)
            3'b000: N = RB;
            3'b001: N = low_sign_ext_11;
            3'b010: N = low_sign_ext_14;
            3'b011: N = {I[20:0], 11'b0};
            3'b100: N = shift_right_logic;
            3'b101: N = shift_right_arith;
            3'b110: N = shift_left_logic;
            3'b111: N = 32'b0;  // Not used, set to 0
            default: N = 32'b0;
        endcase
    end
endmodule