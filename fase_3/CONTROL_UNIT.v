module CONTROL_UNIT (
    input wire [31:0] instruction, // 32-bit instruction input
    output logic [1:0] SRD,        // 2-bit Select target register
    output logic PSW_LE_RE,        // PSW Load / Read Enable
    output logic B,                // Branch
    output logic [2:0] SOH_OP,     // 3-bit Operand handler opcode
    output logic [3:0] ALU_OP,     // 4-bit ALU opcode
    output logic [3:0] RAM_CTRL,   // 4-bit Ram control
    output logic L,                // Select Dataout from RAM
    output logic RF_LE,            // Register File Load Enable
    output logic ID_SR,            // ?-bit Instruction Decode Shift Register (WATCH PRESENTATION TO KNOW THE AMOUNT OF BITS)
    output logic UB,               // Unconditional Branch
);

    wire [7:0] opcode;
    assign opcode = instruction[31:26];  // 6-bit opcode field

    always @* begin
        // Default all signals to 0 (NOP behavior)
        SRD = 2'h0;
        PSW_LE_RE = 0;
        B = 0;
        SOH_OP = 3'h0;
        ALU_OP = 4'h0;
        RAM_CTRL = 4'h0;
        L = 0;
        RF_LE = 0;
        ID_SR = 0;
        UB = 0;

        // If instruction is NOP (all bits zero), keep signals at 0
        if (instruction != 32'h00000000) begin
            case (opcode)
                6'b000000: begin
                end
                6'b000000: begin
                end

                // 24 instructions

                default: ; // unknown opcode → no control
            endcase
        end
    end

endmodule
