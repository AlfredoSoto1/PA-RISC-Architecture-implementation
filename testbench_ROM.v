`include "ROM.v"

module ROM_tb; 
    // Module variables
    wire [31:0] I; //output
    reg [8:0] A; //input

    // ROM module instance
    rom rom1(I, A);

    // Precarga de la memoria desde archivo binario 
    initial begin
      $readmemb("file_precarga_phase_1.txt", rom1.Mem);
    end 

    // Printing results
    initial begin
        A = 9'b0;
        $display("--A--  |  ------I------");
        repeat(4) begin
            #1;

            $display("%d         %b", A, I);
            $display("%d         %h", A, I);
            A = A + 4;
        end
    end

endmodule
