module TAG_ADDER (
    input wire [7:0] B_PC,
    output wire [7:0] R
);
    assign R = B_PC + 8;
endmodule


module TAG (
    input [7:0] B_PC,
    input wire [20:0] offset,
    output reg [7:0] TA,
    output wire [7:0] R
);

    reg [31:0] TA_temp; // Temporary target address

    TAG_ADDER tag_adder (
        .B_PC(B_PC),
        .R(R)
    ); 

    function [31:0] sign_ext;
        input [20:0] in; // Replace N with actual bit width
        begin
            sign_ext = {{(32-20){in[20]}}, in};
        end
    endfunction

    always @(*) begin
        // Calculate the target address (TA) based on the offset and return address
        case (offset[15:13])
            3'b000: begin
                // TA = B_PC + 8 + 4 x sign_ext(w1,w2,w);
                // Shift left by 2 bits to multiply by 4
                TA_temp <= R + (sign_ext({offset[20:16], offset[12:2], offset[0]}) << 2); 
            end
            default:
                // TA = B_PC + 8 + 4 x sign_ext(w1,w);
                TA_temp <= R + (sign_ext({offset[12:2], offset[0]}) << 2);
        endcase

        TA <= TA_temp[7:0]; // Assign the lower 8 bits of the target address
    end
endmodule
