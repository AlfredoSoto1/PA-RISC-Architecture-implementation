module ROM (
    output reg [31:0] I, // Salida de 32 bits (word)
    input [7:0] A        // Dirección de 8 bits (256 localizaciones)
);

    // Memoria de 256 bytes (8 bits cada celda)
    reg [7:0] Mem[0:255]; 

    // Precarga de la memoria desde un archivo de texto externo 
    initial begin
        $readmemb("instruction_memory.txt", Mem);
    end

    // Lectura de una instrucción completa (word) en big-endian
    always @(*) begin
        I = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
    end

endmodule


// module ROM_tb;

//     // Declare signals to drive the ROM module
//     reg [7:0] address;  // 8-bit address input
//     wire [31:0] instruction;  // 32-bit instruction output

//     // Instantiate the ROM module
//     ROM rom_inst (
//         .I(instruction),
//         .A(address)
//     );

//     // Test stimulus to read all memory words
//     initial begin
//         // Loop through all address values from 0 to 255
//         for (address = 8'b00000000; address < 8'b11111111 - 4; address = address + 4) begin
//             #10;  // Wait for 10 time units for the instruction to be available
//             $display("Address: %0d, Instruction: %h", address, instruction);  // Display instruction in hex
//         end

//         // End the simulation
//         $finish;
//     end

// endmodule