module id_ex(
    input wire clk,
    input wire reset,
    input wire LE,

    //Register outputs and offset 
    input wire [31:0] PA, PB, PD,
    input wire [31:0] offset,

    //Control signals
    input wire [20:0] ctrl_in,
    output reg [31:0] PA_EX, PB_EX, PD_EX, Offset_EX,
    output reg [20:0] ctrl_EX,
);

    always @(posedge clk) begin
        if (reset) begin
            PA_EX <= 0;
            PB_EX <= 0;
            PD_EX <= 0;
            Offset_EX <= 0;
            ctrl_EX <= 0;
        end else if (LE) begin
            PA_EX <= PA;
            PB_EX <= PB;
            PD_EX <= PD;
            Offset_EX <= offset;
            ctrl_EX <= ctrl_in;
        end
    end

endmodule

module EX_MEM (
    input wire clk,
    input wire reset,
    input wire LE,

    input wire [31:0] ALU_OUT,
    input wire [31:0] STORE_DATA,
    input wire [4:0] DEST_REG, // optional?
    input wire [4:0] RAM_CTRL,
    input wire RF_LE,

    output reg [31:0] ALU_OUT_MEM,
    output reg [31:0] STORE_DATA_MEM,
    output reg [4:0] DEST_REG_MEM,
    output reg [4:0] RAM_CTRL_MEM,
    output reg RF_LE_MEM
);

    always @(posedge clk) begin
        if (reset) begin
            ALU_OUT_MEM <= 0;
            STORE_DATA_MEM <= 0;
            DEST_REG_MEM <= 0;
            RAM_CTRL_MEM <= 0;
            RF_LE_MEM <= 0;
        end else if (LE) begin
            ALU_OUT_MEM <= ALU_OUT;
            STORE_DATA_MEM <= STORE_DATA;
            DEST_REG_MEM <= DEST_REG;
            RAM_CTRL_MEM <= RAM_CTRL;
            RF_LE_MEM <= RF_LE;
        end
    end

endmodule

module MEM_WB (
    input wire clk,
    input wire reset,
    input wire LE,

    input wire [31:0] WRITE_DATA,
    input wire [4:0] DEST_REG,
    input wire RF_LE,

    output reg [31:0] WRITE_DATA_WB,
    output reg [4:0] DEST_REG_WB,
    output reg RF_LE_WB
);

    always @(posedge clk) begin
        if (reset) begin
            WRITE_DATA_WB <= 0;
            DEST_REG_WB <= 0;
            RF_LE_WB <= 0;
        end else if (LE) begin
            WRITE_DATA_WB <= WRITE_DATA;
            DEST_REG_WB <= DEST_REG;
            RF_LE_WB <= RF_LE;
        end
    end

endmodule
