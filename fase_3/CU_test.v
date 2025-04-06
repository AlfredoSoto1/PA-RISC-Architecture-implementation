`include "CONTROL_UNIT.v"

module tb_CONTROL_UNIT;

    // Inputs
    reg [31:0] instruction;

    // Outputs
    wire [1:0] SRD;
    wire [1:0] PSW_LE_RE;
    wire B;
    wire [2:0] SOH_OP;
    wire [3:0] ALU_OP;
    wire [3:0] RAM_CTRL;
    wire L;
    wire RF_LE;
    wire [1:0] ID_SR;
    wire UB;

    // Instantiate the DUT (Device Under Test)
    CONTROL_UNIT dut (
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
        .UB(UB)
    );

    initial begin
        // Wait for signals to stabilize
        #1;

        // Test ADD
        instruction = 32'b000010_00000_00000_011000_000000;
        #1;
        $display("ADD:");
        $display("SRD=%b, PSW_LE_RE=%b, B=%b, SOH_OP=%b, ALU_OP=%b, RAM_CTRL=%b, L=%b, RF_LE=%b, ID_SR=%b, UB=%b\n",
                 SRD, PSW_LE_RE, B, SOH_OP, ALU_OP, RAM_CTRL, L, RF_LE, ID_SR, UB);

        // Test ADDC
        instruction = 32'b000010_00000_00000_011100_000000;
        #1;
        $display("ADDC:");
        $display("SRD=%b, PSW_LE_RE=%b, B=%b, SOH_OP=%b, ALU_OP=%b, RAM_CTRL=%b, L=%b, RF_LE=%b, ID_SR=%b, UB=%b\n",
                 SRD, PSW_LE_RE, B, SOH_OP, ALU_OP, RAM_CTRL, L, RF_LE, ID_SR, UB);

        // Test SUB
        instruction = 32'b000010_00000_00000_010000_000000;
        #1;
        $display("SUB:");
        $display("SRD=%b, PSW_LE_RE=%b, B=%b, SOH_OP=%b, ALU_OP=%b, RAM_CTRL=%b, L=%b, RF_LE=%b, ID_SR=%b, UB=%b\n",
                 SRD, PSW_LE_RE, B, SOH_OP, ALU_OP, RAM_CTRL, L, RF_LE, ID_SR, UB);

        // ... (los demás tests igual, puedes copiarlos con el mismo patrón)

        $finish;
    end

endmodule


// `include "CONTROL_UNIT.v"

// module tb_CONTROL_UNIT;

//     // Inputs
//     wire [31:0] instruction;

//     // Outputs
//     wire [1:0] SRD;
//     wire [1:0] PSW_LE_RE;
//     wire B;
//     wire [2:0] SOH_OP;
//     wire [3:0] ALU_OP;
//     wire [3:0] RAM_CTRL;
//     wire L;
//     wire RF_LE;
//     wire [1:0] ID_SR;
//     wire UB;

//     // Instantiate the DUT (Device Under Test)
//     CONTROL_UNIT dut (
//         .instruction(instruction),
//         .SRD(SRD),
//         .PSW_LE_RE(PSW_LE_RE),
//         .B(B),
//         .SOH_OP(SOH_OP),
//         .ALU_OP(ALU_OP),
//         .RAM_CTRL(RAM_CTRL),
//         .L(L),
//         .RF_LE(RF_LE),
//         .ID_SR(ID_SR),
//         .UB(UB)
//     );

//     task print_signals;
//       begin
//         $display("Instruction: %h", instruction);
//         $display("SRD=%b, PSW_LE_RE=%b, B=%b, SOH_OP=%b, ALU_OP=%b, RAM_CTRL=%b, L=%b, RF_LE=%b, ID_SR=%b, UB=%b\n",
//                  SRD, PSW_LE_RE, B, SOH_OP, ALU_OP, RAM_CTRL, L, RF_LE, ID_SR, UB);
//       end
//     endtask

//     initial begin
//         // Wait for signals to stabilize
//         #1;

//         // Test ADD
//         instruction = 32'b000010_00000_00000_011000_000000; // opcode = 000010, OP2 = 011000
//         #1 print_signals();

//         // Test ADDC
//         instruction = 32'b000010_00000_00000_011100_000000;
//         #1 print_signals();

//         // Test SUB
//         instruction = 32'b000010_00000_00000_010000_000000;
//         #1 print_signals();

//         // Test OR
//         instruction = 32'b000010_00000_00000_001001_000000;
//         #1 print_signals();

//         // Test BL (Branch and Link)
//         instruction = 32'b111010_000000000000000000000000;
//         #1 print_signals();

//         // Test COMBT
//         instruction = 32'b100000_000000000000000000000000;
//         #1 print_signals();

//         // Test ADDI
//         instruction = 32'b101101_000000000000000000000000;
//         #1 print_signals();

//         // Test SUBI
//         instruction = 32'b100101_000000000000000000000000;
//         #1 print_signals();

//         // Default (NOP)
//         instruction = 32'h00000000;
//         #1 print_signals();

//         $finish;
//     end

// endmodule
