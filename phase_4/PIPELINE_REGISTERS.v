
module PC_FRONT_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'h00;      // Synchronous reset to 0
        else if (LE)
            Q <= D;          // Load input value if LE is high
    end
endmodule


module PC_BACK_REGISTER (
    output reg [7:0] Q,     // 8-bit output 
    input wire [7:0] D,     // 8-bit input
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
);
    always @(posedge Clk) begin
        if (Rst)
            Q <= 8'd4;       // Initialize to 4 on reset
        else if (LE)
            Q <= D;          // Load new value if enabled
    end
endmodule


module IF_ID_REGISTER (
    input wire LE, Rst, Clk  // Load enable, synchronous reset, clock
    
    input wire [7:0]  front_address,       // 8-bit input
    input wire [31:0] fetched_instruction, // 32-bit input
    
    output reg [7:0]  B_PC,                // 8-bit output 
    output reg [31:0] instruction,         // 32-bit output 
    
);
    always @(posedge Clk) begin
        if (Rst)
            B_PC <= 8'h0;                     
            instruction <= 32'h0;               
        else if (LE)
            B_PC <= front_address; 
            instruction <= fetched_instruction; 
    end
endmodule


module ID_EX_REG (
    input wire clk, reset,

    // Register values and addresses
    input wire [31:0] RA_in;
    input wire [31:0] RB_in;
    input wire [7:0] TA_in;
    input wire [7:0] R_in;

    // Condition and Immediate values
    input wire [4:0] RD_in,
    input wire [2:0] COND_in,
    input wire [20:0] IM_in,

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
    input wire SHF_in,

    // Output Register values and addresses
    output reg [31:0] RA_out;
    output reg [31:0] RB_out;
    output reg [7:0] TA_out;
    output reg [7:0] R_out;

    // Output condition and Immediate values
    output reg [4:0] RD_out,
    output reg [2:0] COND_out,
    output reg [20:0] IM_out,

    // Outputs to EX stage
    output reg [1:0] SRD_out,
    output reg [1:0] PSW_LE_RE_out,
    output reg B_out,
    output reg [2:0] SOH_OP_out,
    output reg [3:0] ALU_OP_out,
    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out,
    output reg [1:0] ID_SR_out,
    output reg UB_out,
    output reg SHF_out
);

    always @(posedge clk) begin
        if (reset) begin

            RA_out <= 0;
            RB_out <= 0;
            TA_out <= 0;
            R_out <= 0;

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
            SHF_out <= 0;
        end else begin

            RA_out <= RA_in;
            RB_out <= RB_in;
            TA_out <= TA_in;
            R_out <= R_in;

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
            SHF_out <= SHF_in;
        end
    end
endmodule

module PSW_REG (
  input wire clk,    // Clock signal
  input wire LE,     // Load enable signal
  input wire RE,     // Read enable signal
  input wire C_in,   // Data input (1-bit wide, C/B)
  output wire C_out  // Data output (1-bit wide, C/B)
);

  reg register; // Internal register to store 1-bit data

  // Load data into the register on the rising edge of the clock
  always @(posedge clk) begin
    if (LE) begin
      register <= C_in;
    end
  end

  // Output data only when read enable is high
  assign C_out = RE ? register : 1'b0;

endmodule

module EX_MEM_REG (
    input wire clk, reset,

    input wire [3:0] RAM_CTRL_in,
    input wire L_in,
    input wire RF_LE_in,

    output reg [3:0] RAM_CTRL_out,
    output reg L_out,
    output reg RF_LE_out
);

    always @(posedge clk) begin
        if (reset) begin
            RAM_CTRL_out <= 0;
            L_out <= 0;
            RF_LE_out <= 0;
        end else begin
            RAM_CTRL_out <= RAM_CTRL_in;
            L_out <= L_in;
            RF_LE_out <= RF_LE_in;
        end
    end
endmodule


module MEM_WB_REG (
    input wire clk, reset,

    input wire RF_LE_in,

    output reg RF_LE_out
);

    always @(posedge clk) begin
        if (reset) begin
            RF_LE_out <= 0;
        end else begin
            RF_LE_out <= RF_LE_in;
        end
    end
endmodule