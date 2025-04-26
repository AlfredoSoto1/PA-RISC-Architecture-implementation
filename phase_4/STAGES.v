`include "ROM.v"
`include "RAM.v"
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
  input wire [7:0] TA,

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
        .Rst(RST),
        .Clk(CLK)
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
        .Rst(RST),
        .Clk(CLK)
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

    output wire [4:0] RA,
    output wire [4:0] RB,

    // Control unit signals
    output wire [1:0] PSW_LE_RE,       // 2-bit PSW Load / Read Enable
    output wire B,                     // Branch
    output wire [2:0] SOH_OP,          // 3-bit Operand handler opcode
    output wire [3:0] ALU_OP,          // 4-bit ALU opcode
    output wire [3:0] RAM_CTRL,        // 4-bit Ram control
    output wire L,                     // Select Dataout from RAM
    output wire RF_LE,                 // Register File Load Enable
    output wire [1:0] ID_SR,           // 2-bit Instruction Decode Shift Register
    output wire UB                     // Unconditional Branch
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

  MUX_ID_IDR mux_id_idr (
      .S(CU_SRD),
      .I_0(instruction[4:0]),
      .I_1(instruction[25:21]),
      .I_2(instruction[20:16]),

      .IDR(IDR)
  );

  MUX_CU mux_cu (
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
      .PA(PA), 
      .PB(PB), 

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

  assign RA = instruction[25:21];
  assign RB = RB_SHF_MUX;
  assign IM = instruction[20:0];
  assign COND = instruction[15:13];

endmodule


module EX (
  input wire CLK,

  input wire [7:0] return_address,
  input wire [7:0] target_address,
  input wire [31:0] FPA,
  input wire [31:0] FPB,
  input wire [2:0]  COND,
  input wire [20:0] IM,
  input wire [4:0]  IDR,

  // Control unit signals
  input wire [1:0] PSW_LE_RE,      
  input wire B,                     
  input wire [2:0] SOH_OP,         
  input wire [3:0] ALU_OP,         
  input wire [3:0] RAM_CTRL,        
  input wire L,                    
  input wire RF_LE,                
  input wire UB,

  output wire EX_J,                   
  output wire [7:0] TARGET_ADDRESS,
  output wire [31:0] EX_OUT,                   
  output wire [31:0] EX_DI,                   
  output wire [4:0]  EX_RD,                   
  output wire EX_L,                   
  output wire EX_RF_LE, 
  output wire [3:0] RAM_CTRL_OUT 
);

    assign EX_L = L;
    assign EX_RF_LE = RF_LE;
    assign EX_DI = FPB;
    assign EX_RD = IDR;
    assign TARGET_ADDRESS = target_address;
    assign RAM_CTRL_OUT = RAM_CTRL;

    wire [31:0] SOH_OUT;
    wire [31:0] ALU_OUT;
    wire Ci;

    wire Z;
    wire N; 
    wire C;
    wire V;

    wire J;

    OperandHandler op (
        .RB(FPB),
        .I(IM),   
        .S(SOH_OP),   
        .N(SOH_OUT) 
    );

    ALU alu (
        .A(FPA),         
        .B(SOH_OUT),         
        .Ci(Ci),         
        .OP(ALU_OP),         
        .Out(ALU_OUT),
        .Z(Z),
        .N(N), 
        .C(C),
        .V(V)     
    );

    CH condition_handler (
        .B(B),   
        .Odd(ALU_OUT[0]), 
        .Z(Z), 
        .N(N), 
        .C(C), 
        .V(V),   
        .Cond(COND),
        .J(J)      
    );

    PSW_REG psw (
        .clk(CLK),   
        .LE(PSW_LE_RE[0]),    
        .RE(PSW_LE_RE[1]),    
        .C_in(C),  
        .C_out(Ci)
    );

    MUX_EX_J mux_ex_j (
        .S(UB), 
        .J(J),  
        .O(EX_J)  
    );

    MUX_EX_RETURN_ADDRESS mux_ret(
        .S(UB),      
        .R(return_address),   
        .ALU(ALU_OUT), 
        .O(EX_OUT)
    );

endmodule

module MEM (
    input wire [31:0] EX_OUT,                   
    input wire [31:0] EX_DI,                   
    input wire [4:0]  EX_RD, 
    input wire L,
    input wire EX_RF_LE, 
    input wire [3:0]  RAM_CTRL,        

    output wire [4:0]  MEM_RD, 
    output wire [31:0] MEM_OUT,
    output wire MEM_RF_LE 
);

    wire [31:0] DO; 

    RAM256x8 ram (
        .DataOut(DO), 
        .Enable(RAM_CTRL[0]),  
        .ReadWrite(RAM_CTRL[1]),
        .Address(EX_OUT[7:0]),  
        .Size(RAM_CTRL[3:2]),     
        .DataIn(EX_DI)  
    );

    MUX_MEM mux_mem (
        .S(L),           
        .DO(DO),  
        .EX(EX_OUT),   
        .O(MEM_OUT) 
    );

    assign MEM_RF_LE = EX_RF_LE;
    assign MEM_RD = EX_RD;

endmodule