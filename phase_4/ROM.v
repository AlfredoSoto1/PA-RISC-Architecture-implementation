module ROM (
    output reg [31:0] I, // Salida de 32 bits (word)
    input [7:0] A        // Dirección de 8 bits (256 localizaciones)
);

    // Memoria de 256 bytes (8 bits cada celda)
    reg [7:0] Mem[0:255]; 

    // Precarga de la memoria desde un archivo de texto externo 
    initial begin
        // $readmemb("test_1_instructions.txt", Mem);
        $readmemb("test_2_instructions.txt", Mem);
        // $readmemb("test_3_instructions.txt", Mem);
    end

    // Lectura de una instrucción completa (word) en big-endian
    always @(*) begin
        I = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
    end

endmodule