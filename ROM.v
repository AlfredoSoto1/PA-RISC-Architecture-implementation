module rom256x8 (
    output reg [31:0] Instruction, // Salida de 32 bits (word)
    input [7:0] Address // Dirección de 7 bits (256 localizaciones)
);

    reg [7:0] Mem[0:255]; // Memoria de 256 bytes (8 bits cada celda)

    // Precarga de la memoria desde un archivo de texto externo 
    initial begin
        $readmemb("instruction_memory.txt", Mem);
    end

    // Lectura de una instrucción completa (word) en big-endian
    always @(*) begin
        Instruction = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
    end

endmodule
