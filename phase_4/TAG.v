module TAG_ADDER (
    input [7:0] B_PC,   // Front PC
    output [7:0] R      // Return address PC
);
    assign R = B_PC + 8; // Add 8 to the current B_PC
endmodule

module TAG (
    input [7:0] B_PC,           // Front PC
    input wire [20:0] offset,   // Instruction offset

    output reg [7:0] TA,        // Target address generated
    output reg [7:0] R          // Return address
);

    // Return address from TAG_ADDER
    input wire [7:0] R; 

    TAG_ADDER tag_adder (
        .B_PC(B_PC),
        .R(R)
    ); 

    always @(*) begin
        // Calculate the target address (TA) based on the offset and return address
        case (offset[15:13])
            3'b000: begin
                // TA = B_PC + 8 + 4 x sign_ext(w1,w2,w);
                // Shift left by 2 bits to multiply by 4
                TA = R + (sign_ext({offset[20:16], offset[12:2], offset[0]}) << 2); 
            end
            default:
                // TA = B_PC + 8 + 4 x sign_ext(w1,w);
                TA = R + (sign_ext({offset[12:2], offset[0]}) << 2);
        endcase
    end
endmodule
