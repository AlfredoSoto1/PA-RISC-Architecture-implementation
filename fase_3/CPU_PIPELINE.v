`include "ROM.v"
`include "PC_ADDER.v"
`include "PIPELINE_REGISTERS.v"

`include "CU_MUX.v"
`include "CONTROL_UNIT.v"

module CPU_PIPELINE (
    input wire Clk, Rst, LE, S,

    output wire [31:0] instruction_out,
    output wire [7:0] front_q_out,

    output wire [1:0] SRD_out,
    output wire [1:0] PSW_LE_RE_out,
    output wire B_out,
    output wire [2:0] SOH_OP_out,
    output wire [3:0] ALU_OP_out,
    output wire [3:0] RAM_CTRL_out,
    output wire L_out,
    output wire RF_LE_out,
    output wire [1:0] ID_SR_out,
    output wire UB_out,
    output wire SHF_out,

    output wire [1:0] SRD_EX_out,
    output wire [1:0] PSW_LE_RE_EX_out,
    output wire B_EX_out,
    output wire [2:0] SOH_OP_EX_out,
    output wire [3:0] ALU_OP_EX_out,
    output wire [3:0] RAM_CTRL_EX_out,
    output wire L_EX_out,
    output wire RF_LE_EX_out,
    output wire [1:0] ID_SR_EX_out,
    output wire UB_EX_out,
    output wire SHF_EX_out,

    output wire [3:0] RAM_CTRL_MEM_out,
    output wire L_MEM_out,
    output wire RF_LE_MEM_out,

    output wire RF_LE_WB_out
);

    // 
    // Instruction Fetch Stage
    // 

    wire [31:0] instruction;
    wire [31:0] fetched_instruction;

    wire [7:0] back_q;
    wire [7:0] front_q;
    wire [7:0] next_pc;
    
    PC_BACK_REGISTER back_reg (
        .Q(back_q),
        .D(next_pc),
        .LE(LE),
        .Rst(Rst),
        .Clk(Clk)
    );

    PC_FRONT_REGISTER front_reg (
        .Q(front_q),
        .D(back_q),
        .LE(LE),
        .Rst(Rst),
        .Clk(Clk)
    );

    PC_ADDER pc_adder (
        .currPC(back_q),
        .nextPC(next_pc)
    );

    ROM instr_mem (
        .I(fetched_instruction),
        .A(front_q)
    );

    IF_ID_REGISTER if_id_reg (
        .Q(instruction),
        .D(fetched_instruction),
        .LE(LE),
        .Rst(Rst),
        .Clk(Clk)
    );

    //
    // Instruction Decode Stage
    //

    wire [1:0] SRD;             // 2-bit Select target register
    wire [1:0] PSW_LE_RE;       // 2-bit PSW Load / Read Enable
    wire B;                     // Branch
    wire [2:0] SOH_OP;          // 3-bit Operand handler opcode
    wire [3:0] ALU_OP;          // 4-bit ALU opcode
    wire [3:0] RAM_CTRL;        // 4-bit Ram control
    wire L;                     // Select Dataout from RAM
    wire RF_LE;                 // Register File Load Enable
    wire [1:0] ID_SR;           // 2-bit Instruction Decode Shift Register
    wire UB;                    // Unconditional Branch
    wire SHF;                   // Shift

    wire [1:0] SRD_MUX;
    wire [1:0] PSW_LE_RE_MUX;
    wire B_MUX;
    wire [2:0] SOH_OP_MUX;
    wire [3:0] ALU_OP_MUX;
    wire [3:0] RAM_CTRL_MUX;
    wire L_MUX;
    wire RF_LE_MUX;
    wire [1:0] ID_SR_MUX;
    wire UB_MUX;
    wire SHF_MUX;

    CONTROL_UNIT control_unit (
        .instruction(instruction),
        .SRD(SRD),         
        .PSW_LE_RE(PSW_LE_RE),  
        .B(B),           
        .SOH_OP(SOH_OP), 
        .ALU_OP(ALU_OP),      
        .RAM_CTRL(RAM_CTRL),  
        .L(L),           
        .RF_LE(RF_LE),   
        .ID_SR(ID_SR),   
        .UB(UB),
        .SHF(SHF)
    );

    CU_MUX cu_mux (
        .S(S),

        .SRD_in(SRD),
        .PSW_LE_RE_in(PSW_LE_RE),
        .B_in(B),
        .SOH_OP_in(SOH_OP),
        .ALU_OP_in(ALU_OP),
        .RAM_CTRL_in(RAM_CTRL),
        .L_in(L),
        .RF_LE_in(RF_LE),
        .ID_SR_in(ID_SR),
        .UB_in(UB), 
        .SHF_in(SHF), 

        .SRD_out(SRD_MUX),
        .PSW_LE_RE_out(PSW_LE_RE_MUX),
        .B_out(B_MUX),
        .SOH_OP_out(SOH_OP_MUX),
        .ALU_OP_out(ALU_OP_MUX),
        .RAM_CTRL_out(RAM_CTRL_MUX),
        .L_out(L_MUX),
        .RF_LE_out(RF_LE_MUX),
        .ID_SR_out(ID_SR_MUX),
        .UB_out(UB_MUX),
        .SHF_out(SHF_MUX)
    );

    //
    // Instruction Execution Stage
    //

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

    ID_EX_REG id_ex_reg (
        .clk(Clk),
        .reset(Rst),

        // Control signals from mux
        .SRD_in(SRD_MUX),
        .PSW_LE_RE_in(PSW_LE_RE_MUX),
        .B_in(B_MUX),
        .SOH_OP_in(SOH_OP_MUX),
        .ALU_OP_in(ALU_OP_MUX),
        .RAM_CTRL_in(RAM_CTRL_MUX),
        .L_in(L_MUX),
        .RF_LE_in(RF_LE_MUX),
        .ID_SR_in(ID_SR_MUX),
        .UB_in(UB_MUX),
        .SHF_in(SHF_MUX),

        // Outputs to EX stage
        .SRD_out(SRD_EX),
        .PSW_LE_RE_out(PSW_LE_RE_EX),
        .B_out(B_EX),
        .SOH_OP_out(SOH_OP_EX),
        .ALU_OP_out(ALU_OP_EX),
        .RAM_CTRL_out(RAM_CTRL_EX),
        .L_out(L_EX),
        .RF_LE_out(RF_LE_EX),
        .ID_SR_out(ID_SR_EX),
        .UB_out(UB_EX),
        .SHF_out(SHF_EX)
    );

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
