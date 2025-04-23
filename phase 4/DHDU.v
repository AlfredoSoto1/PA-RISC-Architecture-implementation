module DHDU (
  input wire [4:0] RA,     // Source register 1
  input wire [4:0] RB,     // Source register 2
  input wire [4:0] EX_RD,  // Destination register in EX stage
  input wire EX_RF_LE,     // Write enable signal in EX stage
  input wire [4:0] MEM_RD, // Destination register in MEM stage
  input wire MEM_RF_LE,    // Write enable signal in MEM stage
  input wire [4:0] WB_RD,  // Destination register in WB stage
  input wire WB_RF_LE,     // Write enable signal in WB stage
  input wire EX_L          // Verificar esto no estoy segura lo que hace 
  input wire SR            // Source Register (buscar el tamaño del input)
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

    // Forward from MEM stage
    if (MEM_RF_LE && (MEM_RD != 0) && (MEM_RD == RA)) begin
      A_S = 2'b10;
    end
    if (MEM_RF_LE && (MEM_RD != 0) && (MEM_RD == RB)) begin
      B_S = 2'b10;
    end

    // Forward from EX stage
    if (EX_RF_LE && (EX_RD != 0) && (EX_RD == RA)) begin
      A_S = 2'b01;
    end
    if (EX_RF_LE && (EX_RD != 0) && (EX_RD == RB)) begin
      B_S = 2'b01;
    end
  end

  // Hazard detection logic
  always @(*) begin
    // Default NOP value
    NOP = 1'b0;

    // Detect load-use hazard
    if (EX_RF_LE && (EX_RD != 0) && ((EX_RD == RA) || (EX_RD == RB))) begin
      NOP = 1'b1;
    end
  end

endmodule

// Veriicar si hace correctamente el data fowarding y data harzard detection  
/*
    // Default values
    A_S = 2'b00;  // From register file
    B_S = 2'b00;
    NOP = 1'b0;

    // ========== Forwarding for RA ==========
    if (EX_RF_LE && EX_RD != 0 && EX_RD == RA)
        A_S = 2'b01;  // Forward from EX
    else if (MEM_RF_LE && MEM_RD != 0 && MEM_RD == RA)
        A_S = 2'b10;  // Forward from MEM
    else if (WB_RF_LE && WB_RD!= 0 && WB_RD== RA)
        A_S = 2'b11;  // Forward from WB

    // ========== Forwarding for RB ==========
    if (EX_RF_LE && EX_RD != 0 && EX_RD == RB)
        B_S = 2'b01;  // Forward from EX
    else if (MEM_RF_LE && MEM_RD != 0 && MEM_RD == RB)
        B_S = 2'b10;  // Forward from MEM
    else if (WB_RF_LE && WB_RD != 0 && WB_RD == RB)
        B_S = 2'b11;  // Forward from WB

    // ========== Hazard Detection ==========
    if (EX_RF_LE && (
        (EX_RD != 0 && EX_RD == RA) || 
        (EX_RD != 0 && EX_RD == RB))
    ) begin
        NOP = 1'b1;  // Hazard detected → insert NOP
    end
end

endmodule
*/