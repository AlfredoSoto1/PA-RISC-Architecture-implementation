module cuMux (
    input wire S,

    input wire [1:0] SRD_in,
    input wire [1:0] PSW_LE_RE_in,
    input wire B_in,
    input wire [2:0] SOH_OP_in,
    input wire [3:0] ALU_OP_in,
    input wire [3:0] RAM_CTRL_in,
    input wire L_in,
    input wire RF_LE_in,
    input wire [1:0] ID_SR_in,
    input wire UB_in,

    output reg [1:0] SRD_out,
    output reg [1:0] PSW_LE_RE_out,
    output reg B_out,
    output reg [2:0] SOH_OP_out,
    output reg [3:0] ALU_OP_out,
    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out,
    output reg [1:0] ID_SR_out,
    output reg UB_out
);

    always @(*) begin
        if (S == 1'b1) begin
            SRD_out = 2'b00;
            PSW_LE_RE_out = 2'b00;
            B_out = 1'b0;
            SOH_OP_out = 3'b000;
            ALU_OP_out = 4'b0000;
            RAM_CTRL_out = 4'b0000;
            L_out = 1'b0;
            RF_LE_out = 1'b0;
            ID_SR_out = 2'b00;
            UB_out = 1'b0;
        end else begin
            SRD_out = SRD_in;
            PSW_LE_RE_out = PSW_LE_RE_in;
            B_out = B_in;
            SOH_OP_out = SOH_OP_in;
            ALU_OP_out = ALU_OP_in;
            RAM_CTRL_out = RAM_CTRL_in;
            L_out = L_in;
            RF_LE_out = RF_LE_in;
            ID_SR_out = ID_SR_in;
            UB_out = UB_in;
        end
    end
endmodule
