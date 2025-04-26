`include "STAGES.v"
`include "DHDU.v"

module CPU_PIPELINE (
    input wire CLK, RST
);

    // DHDU signals
    wire LE;
    wire NOP;
    wire [1:0] A_S;
    wire [1:0] B_S;
    wire [1:0] ID_SR;
    wire [4:0] RA;
    wire [4:0] RB;
    wire WB_RF_LE; 
    wire [4:0]  WB_RD;

    // Forwarding signals
    wire [31:0] EX_OUT;
    wire [31:0] MEM_OUT;
    wire [31:0] WB_OUT;

    //
    // FETCH STAGE
    //
    wire J;
    wire [7:0] TA;
    wire [7:0] B_PC;
    wire [7:0] front_q;
    wire [31:0] instruction;
    wire [31:0] fetched_instruction;

    IF if_stage (
        .CLK(CLK), .RST(RST), .LE(LE),
        .S(J),
        .TA(TA),
        .address(front_q),
        .instruction(fetched_instruction)
    );

    IF_ID_REGISTER if_id_reg (
        .LE(LE),
        .Rst(RST),
        .CLR(J),
        .Clk(CLK),

        .front_address(front_q),
        .fetched_instruction(fetched_instruction),

        .B_PC(B_PC),
        .instruction(instruction)
    );

    // 
    // DECODE STAGE
    // 

    wire [7:0]  ID_TA;
    wire [7:0]  ID_RET_ADDRESS;
    wire [31:0] ID_FPA;
    wire [31:0] ID_FPB;
    wire [2:0]  ID_COND;
    wire [20:0] ID_IM;
    wire [4:0]  ID_IDR;
    wire [1:0]  ID_PSW_LE_RE;      // 2-bit PSW Load / Read Enable
    wire ID_B;                     // Branch
    wire [2:0] ID_SOH_OP;          // 3-bit Operand handler opcode
    wire [3:0] ID_ALU_OP;          // 4-bit ALU opcode
    wire [3:0] ID_RAM_CTRL;        // 4-bit Ram control
    wire ID_L;                     // Select Dataout from RAM
    wire ID_RF_LE;                 // Register File Load Enable
    wire ID_UB; 

    ID id_stage (
        .CLK(CLK),
        .S(NOP),
        .R_LE(WB_RF_LE),
        .address(B_PC),
        .instruction(instruction),
        .RD(WB_RD),
        .PD_EX(EX_OUT),
        .PD_MEM(MEM_OUT),
        .PD_WB(WB_OUT),
        
        .A_S(A_S),
        .B_S(B_S),

        .return_address(ID_RET_ADDRESS),
        .target_address(ID_TA),
        .FPA(ID_FPA),
        .FPB(ID_FPB),
        .COND(ID_COND),
        .IM(ID_IM),
        .IDR(ID_IDR),

        .RA(RA),
        .RB(RB),

        // Control unit signals
        .PSW_LE_RE(ID_PSW_LE_RE), 
        .B(ID_B),         
        .SOH_OP(ID_SOH_OP),    
        .ALU_OP(ID_ALU_OP),    
        .RAM_CTRL(ID_RAM_CTRL),  
        .L(ID_L),         
        .RF_LE(ID_RF_LE),     
        .ID_SR(ID_SR),     
        .UB(ID_UB)        
    );

    //
    // Execution Stage
    //

    wire [7:0] EX_RET_ADDRESS;
    wire [7:0] EX_TA_ADDRESS;
    wire [31:0] EX_FPA;
    wire [31:0] EX_FPB;
    wire [2:0]  EX_COND;
    wire [20:0] EX_IM;
    wire [4:0]  EX_IDR;

    wire [1:0] EX_PSW_LE_RE;      
    wire EX_B;                     
    wire [2:0] EX_SOH_OP;         
    wire [3:0] EX_ALU_OP;         
    wire [3:0] EX_RAM_CTRL;        
    wire EX_L;                    
    wire EX_RF_LE;               
    wire EX_UB;

    // EX outputs
    wire [31:0] EX_DI;                   
    wire [4:0]  EX_RD;                   
    wire EX_MEM_L;                   
    wire EX_MEM_RF_LE; 
    wire [3:0] RAM_CTRL; 

    ID_EX_REG id_ex_reg (
        .clk(CLK),
        .reset(RST),

        // Register values and addresses
        .RA_in(ID_FPA),
        .RB_in(ID_FPB),
        .TA_in(ID_TA),
        .R_in(ID_RET_ADDRESS),

        // Condition and Immediate values
        .RD_in(ID_IDR),
        .COND_in(ID_COND),
        .IM_in(ID_IM),

        // Control signals from mux
        .PSW_LE_RE_in(ID_PSW_LE_RE),
        .B_in(ID_B),
        .SOH_OP_in(ID_SOH_OP),
        .ALU_OP_in(ID_ALU_OP),
        .RAM_CTRL_in(ID_RAM_CTRL),
        .L_in(ID_L),
        .RF_LE_in(ID_RF_LE),
        .UB_in(ID_UB),

        // Outputs Register values and addresses
        .RA_out(EX_FPA),
        .RB_out(EX_FPB),
        .TA_out(EX_TA_ADDRESS),
        .R_out(EX_RET_ADDRESS),

        // Outputs Condition and Immediate values
        .RD_out(EX_IDR),
        .COND_out(EX_COND),
        .IM_out(EX_IM),

        // Outputs to EX stage
        .PSW_LE_RE_out(EX_PSW_LE_RE),
        .B_out(EX_B),
        .SOH_OP_out(EX_SOH_OP),
        .ALU_OP_out(EX_ALU_OP),
        .RAM_CTRL_out(EX_RAM_CTRL),
        .L_out(EX_L),
        .RF_LE_out(EX_RF_LE),
        .UB_out(EX_UB)
    );

    EX ex_stage (
        .CLK(CLK),

        .return_address(EX_RET_ADDRESS),
        .target_address(EX_TA_ADDRESS),
        .FPA(EX_FPA),
        .FPB(EX_FPB),
        .COND(EX_COND),
        .IM(EX_IM),
        .IDR(EX_IDR),

        // Control unit signals
        .PSW_LE_RE(EX_PSW_LE_RE),      
        .B(EX_B),                     
        .SOH_OP(EX_SOH_OP),         
        .ALU_OP(EX_ALU_OP),         
        .RAM_CTRL(EX_RAM_CTRL),        
        .L(EX_L),                    
        .RF_LE(EX_RF_LE),                
        .UB(EX_UB),

        // Outputs
        .EX_J(J),                   
        .TARGET_ADDRESS(TA),
        .EX_OUT(EX_OUT),                   
        .EX_DI(EX_DI),                   
        .EX_RD(EX_RD),                   
        .EX_L(EX_MEM_L),                   
        .EX_RF_LE(EX_MEM_RF_LE), 
        .RAM_CTRL_OUT(RAM_CTRL) 
    );

    // 
    // Memory Stage
    // 
    wire [31:0] EX_OUT_IN;
    wire [31:0] EX_DI_IN;
    wire [4:0]  EX_RD_IN;

    wire L_IN;
    wire RF_LE_IN;
    wire [3:0] RAM_CTRL_IN;

    wire [4:0]  MEM_RD;
    wire MEM_RF_LE; 

    EX_MEM_REG ex_mem_reg (
        .clk(CLK),
        .reset(RST),

        .EX_OUT(EX_OUT),                   
        .EX_DI(EX_DI),                   
        .EX_RD(EX_RD), 
        .L(EX_MEM_L),
        .RF_LE(EX_MEM_RF_LE),
        .RAM_CTRL(RAM_CTRL),

        // Outputs
        .EX_OUT_IN(EX_OUT_IN),                   
        .EX_DI_IN(EX_DI_IN),                   
        .EX_RD_IN(EX_RD_IN), 
        .L_IN(L_IN),
        .RF_LE_IN(RF_LE_IN),
        .RAM_CTRL_IN(RAM_CTRL_IN)
    );

    MEM mem_stage (
        .EX_OUT(EX_OUT_IN),                   
        .EX_DI(EX_DI_IN),                   
        .EX_RD(EX_RD_IN), 
        .L(L_IN),
        .EX_RF_LE(RF_LE_IN), 
        .RAM_CTRL(RAM_CTRL_IN),        

        // Outputs
        .MEM_RD(MEM_RD), 
        .MEM_OUT(MEM_OUT),
        .MEM_RF_LE(MEM_RF_LE) 
    );

    //
    // WriteBack Stage
    //

    MEM_WB_REG mem_wb_reg (
        .clk(CLK),
        .reset(RST),

        .MEM_RD(MEM_RD),
        .MEM_OUT(MEM_OUT),
        .MEM_RF_LE(MEM_RF_LE),

        // Output
        .WB_RD(WB_RD),
        .WB_OUT(WB_OUT),
        .WB_RF_LE(WB_RF_LE)
    );

    //
    // Data hazzard detection unit handle
    //
    DHDU dhdu (
        .RA(RA),     
        .RB(RB),     

        .EX_RD(EX_RD),  
        .MEM_RD(MEM_RD), 
        .WB_RD(WB_RD),  

        .EX_RF_LE(EX_RF_LE),
        .MEM_RF_LE(MEM_RF_LE),
        .WB_RF_LE(WB_RF_LE),

        .SR(ID_SR),
        .EX_L(MEM_L), 
        .NOP(NOP),
        .LE(LE),  
        .A_S(A_S),    
        .B_S(B_S)     
    );
endmodule


// Testbench for CPU_PIPELINE

module tb_CPU_PIPELINE;

    reg CLK = 0;
    reg RST = 1;

    CPU_PIPELINE uut (
        .CLK(CLK),
        .RST(RST)
    );

    // Clock: updates every 2 time units
    always #2 CLK = ~CLK;

    task dump_data_memory;
        integer i;
        begin
            $display("Memory content:");
            for (i = 0; i < 256; i = i + 4) begin
                $write("%b %b %b %b\n", 
                uut.mem_stage.ram.Mem[i], 
                uut.mem_stage.ram.Mem[i+1], 
                uut.mem_stage.ram.Mem[i+2], 
                uut.mem_stage.ram.Mem[i+3]);

                // $write("%b %b %b %b\n", 
                // uut.if_stage.instr_mem.Mem[i], 
                // uut.if_stage.instr_mem.Mem[i+1], 
                // uut.if_stage.instr_mem.Mem[i+2], 
                // uut.if_stage.instr_mem.Mem[i+3]);
            end
        end
    endtask

    initial begin
        $display("Starting simulation...");

        // Aplicar reset
        #3 RST = 0;

        // Wait for the simulation to finish
        #100 $display("Program finished.");

        // dump_data_memory();
        $finish;
    end

    initial begin

        // $monitor("SRD: %b | PSW_LE_RE: %b | B: %b | SOH_OP: %b | ALU_OP: %b | RAM_CTRL: %b | L: %b | RF_LE: %b | ID_SR: %b | UB: %b | SHF: %b",
        //     uut.id_stage.control_unit.SRD,
        //     uut.id_stage.control_unit.PSW_LE_RE,
        //     uut.id_stage.control_unit.B,
        //     uut.id_stage.control_unit.SOH_OP,
        //     uut.id_stage.control_unit.ALU_OP,
        //     uut.id_stage.control_unit.RAM_CTRL,
        //     uut.id_stage.control_unit.L,
        //     uut.id_stage.control_unit.RF_LE,
        //     uut.id_stage.control_unit.ID_SR,
        //     uut.id_stage.control_unit.UB,
        //     uut.id_stage.control_unit.SHF
        // );
        
        $monitor("RA: %b | RB: %b | PA: %b | PB: %b | alu: %b",
            uut.id_stage.reg_file.RA,
            uut.id_stage.reg_file.RB,
            uut.id_stage.reg_file.PA,
            uut.id_stage.reg_file.PB,
            uut.id_ex_reg.IM_out
        );

        // $monitor("ALU_OUT: %b",
        //     uut.ex_stage.EX_OUT
        // );

        // Monitor for test #3 (Validation program)
        // $monitor("Front: %d | GR1: %d | GR2: %d | GR3: %d | GR5: %d | GR6: %d",
        //     uut.if_stage.front_q,
        //     uut.id_stage.reg_file.R1.Q,
        //     uut.id_stage.reg_file.R2.Q,
        //     uut.id_stage.reg_file.R3.Q,
        //     uut.id_stage.reg_file.R5.Q,
        //     uut.id_stage.reg_file.R6.Q
        // );
    end

endmodule
