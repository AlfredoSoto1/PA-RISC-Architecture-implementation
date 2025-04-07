`include "CPU_PIPELINE.v"

module CPU_PIPELINE_tb;

    // Inputs
    reg Clk;
    reg Rst;
    reg LE;
    reg S;

    // Outputs
    wire [31:0] instruction_out;
    wire [7:0] front_q_out;

    wire [1:0] SRD_out;
    wire [1:0] PSW_LE_RE_out;
    wire B_out;
    wire [2:0] SOH_OP_out;
    wire [3:0] ALU_OP_out;
    wire [3:0] RAM_CTRL_out;
    wire L_out;
    wire RF_LE_out;
    wire [1:0] ID_SR_out;
    wire UB_out;

    wire [1:0] SRD_EX_out;
    wire [1:0] PSW_LE_RE_EX_out;
    wire B_EX_out;
    wire [2:0] SOH_OP_EX_out;
    wire [3:0] ALU_OP_EX_out;
    wire [3:0] RAM_CTRL_EX_out;
    wire L_EX_out;
    wire RF_LE_EX_out;
    wire [1:0] ID_SR_EX_out;
    wire UB_EX_out;

    wire [3:0] RAM_CTRL_MEM_out;
    wire L_MEM_out;
    wire RF_LE_MEM_out;

    wire RF_LE_WB_out;

    // Instantiate the CPU pipeline
    CPU_PIPELINE uut (
        .Clk(Clk),
        .Rst(Rst),
        .LE(LE),
        .S(S),

        .front_q_out(front_q_out),

        .instruction_out(instruction_out),
        
        .SRD_out(SRD_out),
        .PSW_LE_RE_out(PSW_LE_RE_out),
        .B_out(B_out),
        .SOH_OP_out(SOH_OP_out),
        .ALU_OP_out(ALU_OP_out),
        .RAM_CTRL_out(RAM_CTRL_out),
        .L_out(L_out),
        .RF_LE_out(RF_LE_out),
        .ID_SR_out(ID_SR_out),
        .UB_out(UB_out),
        
        .SRD_EX_out(SRD_EX_out),
        .PSW_LE_RE_EX_out(PSW_LE_RE_EX_out),
        .B_EX_out(B_EX_out),
        .SOH_OP_EX_out(SOH_OP_EX_out),
        .ALU_OP_EX_out(ALU_OP_EX_out),
        .RAM_CTRL_EX_out(RAM_CTRL_EX_out),
        .L_EX_out(L_EX_out),
        .RF_LE_EX_out(RF_LE_EX_out),
        .ID_SR_EX_out(ID_SR_EX_out),
        .UB_EX_out(UB_EX_out),
        
        .RAM_CTRL_MEM_out(RAM_CTRL_MEM_out),
        .L_MEM_out(L_MEM_out),
        .RF_LE_MEM_out(RF_LE_MEM_out),
        
        .RF_LE_WB_out(RF_LE_WB_out)
    );

    // Clock generation: each cycle is 2 time units
    always #2 Clk = ~Clk;

    initial begin
        // Initialize inputs
        Clk = 0;
        Rst = 1;
        LE = 1;
        S = 0;

        // Apply reset
        #3;
        Rst = 0;

        // Change LE to 0 at time 48
        #48;
        LE = 0;

        // Change S to 1 at time 60
        #60;
        S = 1;

        #200;
        // Finish simulation
        $finish;
    end

    // Intermediate nets for monitoring
    wire [31:0] instr_out = instruction_out;
    wire [7:0] front_q_out_int = front_q_out;
    wire [9:0] cu_signals = {SRD_out, PSW_LE_RE_out, B_out, SOH_OP_out, ALU_OP_out, RAM_CTRL_out, L_out, RF_LE_out, ID_SR_out, UB_out};
    wire [9:0] ex_signals = {SRD_EX_out, PSW_LE_RE_EX_out, B_EX_out, SOH_OP_EX_out, ALU_OP_EX_out, RAM_CTRL_EX_out, L_EX_out, RF_LE_EX_out, ID_SR_EX_out, UB_EX_out};
    wire [7:0] mem_signals = {RAM_CTRL_MEM_out, L_MEM_out, RF_LE_MEM_out};
    wire rf_le_wb_signal = RF_LE_WB_out;

    reg [63:0] instr_keyword;

    // Decode instruction keyword based on opcode
    always @(*) begin
      case (instruction_out[31:26])
        6'b000010: begin
          case (instruction_out[11:6])
            6'b011000: instr_keyword = "ADD";
            6'b011100: instr_keyword = "ADDC";
            6'b101000: instr_keyword = "ADDL";
            6'b010000: instr_keyword = "SUB";
            6'b010100: instr_keyword = "SUBB";
            6'b001001: instr_keyword = "OR";
            6'b001010: instr_keyword = "XOR";
            6'b001000: instr_keyword = "AND";
            default:   instr_keyword = "NOP";
          endcase
        end
        6'b010010: instr_keyword = "LDW";
        6'b010001: instr_keyword = "LDH";
        6'b010000: instr_keyword = "LDB";
        6'b001101: instr_keyword = "LDO";
        6'b001000: instr_keyword = "LDIL";
        6'b011010: instr_keyword = "STW";
        6'b011001: instr_keyword = "STH";
        6'b011000: instr_keyword = "STB";
        6'b111010: instr_keyword = "BL";
        6'b100000: instr_keyword = "COMBT";
        6'b100010: instr_keyword = "COMBF";
        6'b101101: instr_keyword = "ADDI";
        6'b100101: instr_keyword = "SUBI";
        6'b110100: begin
          case (instruction_out[12:10])
            3'b110: instr_keyword = "EXTRU";
            3'b111: instr_keyword = "EXTRS";
            default:instr_keyword = "NOP";
          endcase
        end
        6'b110101: instr_keyword = "ZDEP";
        default:   instr_keyword = "NOP";
      endcase
    end


    // Monitor the instruction and control signals
    initial begin
      $monitor("Time=%0t | Instruction=%b | Opcode=%s | Front_q=%d | CU Signals=%b | EX Signals=%b | MEM Signals=%b | WB Signals=%b",
                $time, instr_out, instr_keyword, front_q_out_int, cu_signals, ex_signals, mem_signals, rf_le_wb_signal);
    end

endmodule
