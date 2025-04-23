module TAG (
    input wire [7:0] front_pc,
    input wire [20:0] offset_in,  // Sign-extended offset from instruction
    input wire cond_eval,        // Output from ConditionHandler
    input wire bl,               // BL signal

    output reg [7:0] pc_back_out,     // Output for PC Back
    output reg [7:0] pc_front_out,    // Output for PC Front
    output reg [7:0] return_address   // Address to store in GR[t] (only for BL)
);
    wire [7:0] offset_scaled;
    wire [7:0] front_plus_8;
    wire [7:0] tag_result;

    // Scale offset: 4 * offset
    assign offset_scaled = offset_in[7:0] << 2;

    //Front + 8
    assign front_plus_8 = front_pc + 8;

    //TAG = Front + 8 + (4 × offset)
    assign tag_result = front_plus_8 + offset_scaled;

    always @(*) begin
        if (cond_eval) begin
            pc_back_out = tag_result;
            pc_front_out = tag_result;

            // Save return address if it's a BL instruction
            return_address = bl ? front_plus_8 : 0;
        end else begin
            pc_back_out = front_pc;
            pc_front_out = front_pc;
            return_address = 0;
        end
    end
endmodule
