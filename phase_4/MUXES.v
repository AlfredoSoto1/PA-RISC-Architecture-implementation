module MUX_CU (
    input wire S,

    input wire [1:0] PSW_LE_RE_in,
    input wire B_in,
    input wire [2:0] SOH_OP_in,
    input wire [3:0] ALU_OP_in,
    input wire [3:0] RAM_CTRL_in,
    input wire L_in,
    input wire RF_LE_in,
    input wire UB_in,
    input wire SHF_in,

    output reg [1:0] PSW_LE_RE_out,
    output reg B_out,
    output reg [2:0] SOH_OP_out,
    output reg [3:0] ALU_OP_out,
    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out,
    output reg UB_out,
    output reg SHF_out
);

    always @(*) begin
        if (S == 1'b1) begin
            PSW_LE_RE_out = 2'b00;
            B_out = 1'b0;
            SOH_OP_out = 3'b000;
            ALU_OP_out = 4'b0000;
            RAM_CTRL_out = 4'b0000;
            L_out = 1'b0;
            RF_LE_out = 1'b0;
            UB_out = 1'b0;
            SHF_out = 1'b0;
        end else begin
            PSW_LE_RE_out = PSW_LE_RE_in;
            B_out = B_in;
            SOH_OP_out = SOH_OP_in;
            ALU_OP_out = ALU_OP_in;
            RAM_CTRL_out = RAM_CTRL_in;
            L_out = L_in;
            RF_LE_out = RF_LE_in;
            UB_out = UB_in;
            SHF_out = SHF_in;
        end
    end
endmodule


module MUX_IF (
    input wire S,           // Jump signal
    input wire [7:0] TA,    // Target Address
    input wire [7:0] back,  // Back Address

    output reg [7:0] O      // Output Address
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= TA;
        end else begin
            O <= back;
        end
    end
endmodule


module MUX_ID_IDR (
    input wire [1:0] S,     // Select slot for target register
    input wire [4:0] I_0,   // I[4:0]
    input wire [4:0] I_1,   // I[25:21]
    input wire [4:0] I_2,   // I[20:16]

    output reg [4:0] IDR    // Target Register
);

    always @(*) begin
        case (S)
            2'b00: IDR <= I_0; // I[4:0]
            2'b01: IDR <= I_1; // I[25:21]
            2'b10: IDR <= I_2; // I[20:16]
            default: IDR <= 8'b00000000; // Default case
        endcase
    end
endmodule

module MUX_ID_SHF (
    input wire S,   // Select slot for SHF register
    input wire [4:0] RA,  // Register A 
    input wire [4:0] RB,  // Register B 

    output reg [4:0] O    // Register for shifting
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= RA;     
        end else begin
            O <= RB;     
        end
    end
endmodule

module MUX_ID_FW_P (
    input wire [1:0] S,    // Select slot for P register
    input wire [31:0] RP,   // 
    input wire [31:0] EX,   // 
    input wire [31:0] MEM,  // 
    input wire [31:0] WB,   // 

    output reg [31:0] FW_P  // Forwarding Data from Register
);

    always @(*) begin
        case (S)
            2'b00: FW_P <= RP;  // Register P
            2'b01: FW_P <= EX;  // Register EX
            2'b10: FW_P <= MEM; // Register MEM
            2'b11: FW_P <= WB;  // Register WB
            default: FW_P <= 5'b00000; // Default case
        endcase
    end
endmodule

module MUX_EX_J (
    input wire S, // Select slot for P register
    input wire J, // Jump flag (only for conditional jumps) 

    output reg O  // Jump signal 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= 1'b1;  // Always jump
        end else begin
            O <= J;     // Jump signal
        end
    end
endmodule

module MUX_EX_RETURN_ADDRESS (
    input wire S,          // Select return address or ALU output
    input wire [7:0]  R,   // Return address 
    input wire [31:0] ALU, // ALU output 

    output reg [31:0] O    // 32 bit output data 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= {24'b0, R};  // Return address
        end else begin
            O <= ALU; // ALU output
        end
    end
endmodule


module MUX_MEM (
    input wire S,           // Select ram output or EX output
    input wire [31:0] DO,   // Data out from memory 
    input wire [31:0] EX,   // EX output 

    output reg [31:0] O     // 32 bit output data 
);

    always @(*) begin
        if (S == 1'b1) begin
            O <= DO;  // Data out from memory
        end else begin
            O <= EX;  // EX output
        end
    end
endmodule