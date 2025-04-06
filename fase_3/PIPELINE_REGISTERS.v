module ID_EX_REG (
    input wire clk, reset, load_enable,

    // Instruction/control inputs
    input wire [31:0] PA, PB, PD,
    input wire [31:0] Offset,

    // Control signals from mux
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

    // Outputs to EX stage
    output reg [31:0] PA_out, PB_out, PD_out,
    output reg [31:0] Offset_out,

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

    always @(posedge clk) begin
        if (reset) begin
            PA_out <= 0; PB_out <= 0; PD_out <= 0;
            Offset_out <= 0;

            SRD_out <= 0;
            PSW_LE_RE_out <= 0;
            B_out <= 0;
            SOH_OP_out <= 0;
            ALU_OP_out <= 0;
            RAM_CTRL_out <= 0;
            L_out <= 0;
            RF_LE_out <= 0;
            ID_SR_out <= 0;
            UB_out <= 0;
        end else if (load_enable) begin
            PA_out <= PA; PB_out <= PB; PD_out <= PD;
            Offset_out <= Offset;

            SRD_out <= SRD_in;
            PSW_LE_RE_out <= PSW_LE_RE_in;
            B_out <= B_in;
            SOH_OP_out <= SOH_OP_in;
            ALU_OP_out <= ALU_OP_in;
            RAM_CTRL_out <= RAM_CTRL_in;
            L_out <= L_in;
            RF_LE_out <= RF_LE_in;
            ID_SR_out <= ID_SR_in;
            UB_out <= UB_in;
        end
    end
endmodule


module EX_MEM_REG (
    input wire clk, reset, load_enable,

    input wire [31:0] ALU_result,
    input wire [31:0] PB, // Store data
    input wire [4:0] dest_reg,
    input wire [3:0] RAM_CTRL,
    input wire RF_LE,

    output reg [31:0] ALU_result_out,
    output reg [31:0] PB_out,
    output reg [4:0] dest_reg_out,
    output reg [3:0] RAM_CTRL_out,
    output reg RF_LE_out
);

    always @(posedge clk) begin
        if (reset) begin
            ALU_result_out <= 0;
            PB_out <= 0;
            dest_reg_out <= 0;
            RAM_CTRL_out <= 0;
            RF_LE_out <= 0;
        end else if (load_enable) begin
            ALU_result_out <= ALU_result;
            PB_out <= PB;
            dest_reg_out <= dest_reg;
            RAM_CTRL_out <= RAM_CTRL;
            RF_LE_out <= RF_LE;
        end
    end
endmodule


module MEM_WB_REG (
    input wire clk, reset, load_enable,

    input wire [4:0] dest_reg,
    input wire [31:0] write_data,
    input wire RF_LE,

    output reg [4:0] dest_reg_out,
    output reg [31:0] write_data_out,
    output reg RF_LE_out
);

    always @(posedge clk) begin
        if (reset) begin
            dest_reg_out <= 0;
            write_data_out <= 0;
            RF_LE_out <= 0;
        end else if (load_enable) begin
            dest_reg_out <= dest_reg;
            write_data_out <= write_data;
            RF_LE_out <= RF_LE;
        end
    end
endmodule
