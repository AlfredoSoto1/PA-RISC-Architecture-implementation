`include "ROM.v"
`include "PC_ADDER.v"
`include "PIPELINE_REGISTERS.v"

`include "CU.v"
`include "TAG.v"
`include "ALU.v"
`include "OH.v"
`include "CH.v"
`include "MUXES.v"
`include "TP_REGISTER_FILE.v"

module IF (
  input wire CLK, RST, LE,
  input wire S,

  output wire [7:0]  address,
  output wire [31:0] instruction
);

    wire [7:0] B_PC;
    wire [7:0] back_q;
    wire [7:0] front_q;
    wire [7:0] next_pc;
    wire [7:0] jump_mux;
    
    PC_BACK_REGISTER back_reg (
        .Q(back_q),
        .D(next_pc),
        .LE(LE),
        .Rst(Rst),
        .Clk(Clk)
    );

    MUX_IF pc_mux (
        .S(S),
        .TA(TA),
        .back(back_q),
        .O(jump_mux)
    );

    PC_FRONT_REGISTER front_reg (
        .Q(front_q),
        .D(jump_mux),
        .LE(LE),
        .Rst(Rst),
        .Clk(Clk)
    );

    PC_ADDER pc_adder (
        .currPC(jump_mux),
        .nextPC(next_pc)
    );

    ROM instr_mem (
        .I(instruction),
        .A(front_q)
    );

    assign address = front_q;

endmodule

module ID (
  input wire CLK,
  input wire S,
  input wire R_LE,
  input wire [7:0]  address,
  input wire [31:0] instruction,
  input wire [4:0]  RD,
  input wire [31:0] PD_EX,
  input wire [31:0] PD_MEM,
  input wire [31:0] PD_WB,
  
  input wire [1:0]  A_S,
  input wire [1:0]  B_S,

  output wire [7:0] return_address,
  output wire [7:0] target_address,
  output wire [31:0] FPA,
  output wire [31:0] FPB,
  output wire [2:0]  COND,
  output wire [20:0] IM,
  output wire [4:0]  IDR,

  // Control unit signals
  output wire [1:0] PSW_LE_RE;       // 2-bit PSW Load / Read Enable
  output wire B;                     // Branch
  output wire [2:0] SOH_OP;          // 3-bit Operand handler opcode
  output wire [3:0] ALU_OP;          // 4-bit ALU opcode
  output wire [3:0] RAM_CTRL;        // 4-bit Ram control
  output wire L;                     // Select Dataout from RAM
  output wire RF_LE;                 // Register File Load Enable
  output wire [1:0] ID_SR;           // 2-bit Instruction Decode Shift Register
  output wire UB;                    // Unconditional Branch
);

  wire [4:0] RB_SHF_MUX;
  
  // From Control unit
  wire [1:0] CU_SRD;
  wire [1:0] CU_PSW_LE_RE;
  wire CU_B;
  wire [2:0] CU_SOH_OP;
  wire [3:0] CU_ALU_OP;
  wire [3:0] CU_RAM_CTRL;
  wire CU_L;
  wire CU_RF_LE;
  wire CU_UB;
  wire CU_SHF;
  
  // From Multiplexer of control unit
  wire MUX_SHF;

  wire [31:0] PA;
  wire [31:0] PB;

  CONTROL_UNIT control_unit (
      .instruction(instruction),
      .SRD(CU_SRD),             // Not pass to MUX
      .PSW_LE_RE(CU_PSW_LE_RE),  
      .B(CU_B),           
      .SOH_OP(CU_SOH_OP), 
      .ALU_OP(CU_ALU_OP),      
      .RAM_CTRL(CU_RAM_CTRL),  
      .L(CU_L),           
      .RF_LE(CU_RF_LE),   
      .ID_SR(ID_SR),           // Not pass to MUX
      .UB(CU_UB),
      .SHF(CU_SHF)
  );

  MUX_ID_IRD mux_id_idr (
      .S(CU_SRD),
      .I_0(instruction[4:0]),
      .I_1(instruction[25:21]),
      .I_2(instruction[20:16]),

      .IDR(IDR)
  );

  CU_MUX cu_mux (
      .S(S),

      .PSW_LE_RE_in(CU_PSW_LE_RE),
      .B_in(CU_B),
      .SOH_OP_in(CU_SOH_OP),
      .ALU_OP_in(CU_ALU_OP),
      .RAM_CTRL_in(CU_RAM_CTRL),
      .L_in(CU_L),
      .RF_LE_in(CU_RF_LE),
      .UB_in(CU_UB), 
      .SHF_in(CU_SHF), 

      .PSW_LE_RE_out(PSW_LE_RE),
      .B_out(B),
      .SOH_OP_out(SOH_OP),
      .ALU_OP_out(ALU_OP),
      .RAM_CTRL_out(RAM_CTRL),
      .L_out(L),
      .RF_LE_out(RF_LE),
      .UB_out(UB),
      .SHF_out(MUX_SHF)
  );

  MUX_ID_SHF mux_id_shf (
      .S(MUX_SHF),

      .RA(instruction[25:21]),
      .RB(instruction[20:16]),
      .O(RB_SHF_MUX)
  );

  TAG tag (
      .B_PC(address),           
      .offset(instruction[20:0]), 

      .TA(target_address),                
      .R(return_address)              
  );

  TP_REGISTER_FILE reg_file (
      .PA(RA), 
      .PB(RB), 

      .PW(PD_WB), 

      .RA(instruction[25:21]),
      .RB(RB_SHF_MUX),
      .RW(RD),

      .Clk(CLK),
      .LE(R_LE)
  );

  MUX_ID_FW_P fwpa (
      .S(A_S),

      .RP(PA),  
      .EX(PD_EX),  
      .MEM(PD_MEM), 
      .WB(PD_WB),  

      .FW_P(FPA)
  );

  MUX_ID_FW_P fwpb (
      .S(B_S),

      .RP(PB),  
      .EX(PD_EX),  
      .MEM(PD_MEM), 
      .WB(PD_WB),  

      .FW_P(FPB)
  );

  assign IM = instruction[20:0];
  assign COND = instruction[15:13];

endmodule


module EX (
  input wire [7:0] return_address,
  input wire [7:0] target_address,
  input wire [31:0] FPA,
  input wire [31:0] FPB,
  input wire [2:0]  COND,
  input wire [20:0] IM,
  input wire [4:0]  IDR,

  // Control unit signals
  input wire [1:0] PSW_LE_RE;       
  input wire B;                     
  input wire [2:0] SOH_OP;         
  input wire [3:0] ALU_OP;         
  input wire [3:0] RAM_CTRL;        
  input wire L;                    
  input wire RF_LE;                
  input wire [1:0] ID_SR;           
  input wire UB;                   
);
    wire [1:0] SRD_EX;
    wire [1:0] PSW_LE_RE_EX;
    wire B_EX;
    wire [2:0] SOH_OP_EX;
    wire [3:0] ALU_OP_EX;
    wire [3:0] RAM_CTRL_EX;
    wire L_EX;
    wire RF_LE_EX;
    wire [1:0] ID_SR_EX;
    wire UB_EX;
    wire SHF_EX;

endmodule
    //
    // Instruction Memory Stage
    //

    wire [3:0] RAM_CTRL_MEM;
    wire L_MEM;
    wire RF_LE_MEM;

    EX_MEM_REG ex_mem_reg (
        .clk(Clk),
        .reset(Rst),

        // Control signals from ID_EX_REG
        .RAM_CTRL_in(RAM_CTRL_EX),
        .L_in(L_EX),
        .RF_LE_in(RF_LE_EX),

        // Outputs to MEM stage
        .RAM_CTRL_out(RAM_CTRL_MEM),
        .L_out(L_MEM),
        .RF_LE_out(RF_LE_MEM)
    );

    //
    // Instruction WriteBack Stage
    //

    wire RF_LE_WB;

    MEM_WB_REG mem_wb_reg (
        .clk(Clk),
        .reset(Rst),

        // Control signals from EX_MEM_REG
        .RF_LE_in(RF_LE_MEM),

        // Outputs to WB stage
        .RF_LE_out(RF_LE_WB)
    );

// IF stage
assign instruction_out = instruction;
assign front_q_out = front_q;

// Control Unit output (after CU_MUX)
assign SRD_out = SRD_MUX;
assign PSW_LE_RE_out = PSW_LE_RE_MUX;
assign B_out = B_MUX;
assign SOH_OP_out = SOH_OP_MUX;
assign ALU_OP_out = ALU_OP_MUX;
assign RAM_CTRL_out = RAM_CTRL_MUX;
assign L_out = L_MUX;
assign RF_LE_out = RF_LE_MUX;
assign ID_SR_out = ID_SR_MUX;
assign UB_out = UB_MUX;
assign SHF_out = SHF_MUX;

// EX stage
assign SRD_EX_out = SRD_EX;
assign PSW_LE_RE_EX_out = PSW_LE_RE_EX;
assign B_EX_out = B_EX;
assign SOH_OP_EX_out = SOH_OP_EX;
assign ALU_OP_EX_out = ALU_OP_EX;
assign RAM_CTRL_EX_out = RAM_CTRL_EX;
assign L_EX_out = L_EX;
assign RF_LE_EX_out = RF_LE_EX;
assign ID_SR_EX_out = ID_SR_EX;
assign UB_EX_out = UB_EX;
assign SHF_EX_out = SHF_EX;

// MEM stage
assign RAM_CTRL_MEM_out = RAM_CTRL_MEM;
assign L_MEM_out = L_MEM;
assign RF_LE_MEM_out = RF_LE_MEM;

// WB stage
assign RF_LE_WB_out = RF_LE_WB;


endmodule
