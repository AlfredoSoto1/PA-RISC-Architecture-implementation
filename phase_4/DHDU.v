module DHDU (
  input wire [4:0] RA,     // Source register 1
  input wire [4:0] RB,     // Source register 2

  input wire [4:0] EX_RD,  // Destination register in EX stage
  input wire [4:0] MEM_RD, // Destination register in MEM stage
  input wire [4:0] WB_RD,  // Destination register in WB stage

  input wire EX_RF_LE,     // Destination register write enable signal in EX stage
  input wire MEM_RF_LE,    // Destination register write enable signal in MEM stage
  input wire WB_RF_LE,     // Destination register write enable signal in WB stage

  input wire [1:0] SR      // Selected operand register (RA, RB)
  input wire EX_L          // Forward hazard from execution phase 
  output reg NOP,          // Stall signal for pipeline
  output reg LE            // Load enable signal for the ID stage 
  output reg [1:0] A_S,    // Forwarding control for RA
  output reg [1:0] B_S     // Forwarding control for RB
);

  // Forwarding logic
  always @(*) begin
    // Default. No hazard detected 
    A_S = 2'b00;
    B_S = 2'b00;

    // Under normal conditions
    NOP = 1'b0;
    LE = 1'b1; 

    if (EX_L && ((SR == 2'b01 && (RA == EX_RD)) || (SR == 2'b10 && (RB == EX_RD)))) begin
      LE = 0; // Disable load enable signal
      NOP = 1; // Set NOP signal to indicate hazard
    end else begin

      // Criteria for Hazard Detection for Source Register RA
      if (SR == 2'b01) begin
        if (EX_RF_LE && (RA == EX_RD)) begin
          A_S = 2'b01; // Forward from EX stage
        end else if (MEM_RF_LE && (RA == MEM_RD)) begin
          A_S = 2'b10; // Forward from MEM stage
        end else if (WB_RF_LE && (RA == WB_RD)) begin
          A_S = 2'b11; // Forward from WB stage
        end else begin
          A_S = 2'b00; // No forwarding
        end
      end

      // Criteria for Hazard Detection for Source Register RB
      if (SR == 2'b10) begin
        if (EX_RF_LE && (RB == EX_RD)) begin
          B_S = 2'b01; // Forward from EX stage
        end else if (MEM_RF_LE && (RB == MEM_RD)) begin
          B_S = 2'b10; // Forward from MEM stage
        end else if (WB_RF_LE && (RB == WB_RD)) begin
          B_S = 2'b11; // Forward from WB stage
        end else begin
          B_S = 2'b00; // No forwarding
        end
      end
    end
  end
endmodule