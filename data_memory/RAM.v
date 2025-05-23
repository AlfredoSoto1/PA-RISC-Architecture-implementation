module ram256x8 (
    output reg [31:0] DataOut, // 32 bit data output
    input Enable,              // enabling signal
    input ReadWrite,           // 0: Read, 1: Write
    input [7:0] Address,       // 8 bit memory address from [0, 255]
    input [1:0] Size,          // 00: byte, 01: halfword, 10: word
    input [31:0] DataIn        // 32 bit data input
);
    
    reg [7:0] Mem[0:255]; // Memoria de 256 bytes

    // Precarga de memoria desde un archivo de texto
    initial begin
        $readmemb("file_precarga_phase_1.txt", Mem);
    end

    always @(*) begin
        // Read from memory if ReadWrite is enabled
        // use bigendian as manual suggests
        if (Enable && !ReadWrite) begin
            case (Size)
                2'b00: DataOut = {24'b0, Mem[Address]}; // Byte
                2'b01: DataOut = {16'b0, Mem[Address], Mem[Address+1]}; // Halfword
                2'b10: DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]}; // Word
                default: DataOut = 32'b0;
            endcase
        end

   // always @(posedge Enable) begin
        // Write to memory if ReadWrite is enabled
        // use bigendian as manual suggests
        if (ReadWrite && Enable) begin
            case (Size)
                2'b00: Mem[Address] <= DataIn[7:0]; // Byte
                2'b01: begin // Halfword (big-endian)
                    Mem[Address]   <= DataIn[15:8];
                    Mem[Address+1] <= DataIn[7:0];
                end
                2'b10: begin // Word (big-endian)
                    Mem[Address]   <= DataIn[31:24];
                    Mem[Address+1] <= DataIn[23:16];
                    Mem[Address+2] <= DataIn[15:8];
                    Mem[Address+3] <= DataIn[7:0];
                end
            endcase
        end
    end
endmodule
