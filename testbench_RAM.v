`include "RAM.v"

module RAM_tb;

    wire [31:0] DataOut;
    reg Enable, ReadWrite, SE;
    reg [6:0] Address; 
    reg [31:0] DataIn;
    reg [1:0] Size;

    // Instancia de la RAM
    ram256x8 ram1 (DataOut, Enable, ReadWrite, Address, DataIn, Size);

    // Precarga de la memoria desde archivo binario
    initial begin
        $readmemb("file_precarga_phase_1.txt", ram1.Mem);
    end

    // Testbench del RAM 
    initial begin

        // Leer un word de las localizaciones 0, 4, 8 y 12
        Address = 7'b0000000;
        Enable = 1'b1;
        ReadWrite = 1'b0;
        Size = 2'b10; // Word

        $display("Reading a word from locations 0, 4, 8, and 12:");
        repeat(4) begin
            #1;
            $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
            Address = Address + 4;
        end  

        // Leer un byte en 0, un halfword en 2 y un halfword en 4 (sin signo)
        Address = 7'b0000000;
        Size = 2'b00; // Byte
        SE = 1'b0; // Unsigned
        $display("\nReading unsigned byte at 0, halfword at 2 and 4:");
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
        Address = Address + 2;
        Size = 2'b01; // Halfword
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
        Address = Address + 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Leer los mismos valores pero con signo
        Address = 7'b0000000;
        SE = 1'b1; // Signed
        $display("\nReading signed byte at 0, halfword at 2 and 4:");
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
        Address = Address + 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
        Address = Address + 2;
        #1;
        $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);

        // Escribir valores en memoria
        Enable = 1'b1;
        ReadWrite = 1'b1; // Write
        $display("\nWriting data to memory:");

        // Byte en 0
        Address = 7'b0000000;
        Size = 2'b00;
        DataIn = 32'hA6;
        #1;

        // Halfword en 2
        Address = Address + 2;
        Size = 2'b01;
        DataIn = 32'hBBDD;
        #1;

        // Halfword en 4
        Address = Address + 2;
        Size = 2'b01;
        DataIn = 32'h5419;
        #1;

        // Word en 8
        Address = Address + 4;
        Size = 2'b10;
        DataIn = 32'hABCDEF01;
        #1;

        // Leer nuevamente un Word en 0, 4 y 8
        Address = 7'b0000000;
        Size = 2'b10;
        Enable = 1'b1;
        ReadWrite = 1'b0;

        $display("\nReading word from 0, 4, and 8:");
        repeat(3) begin
            #1;
            $display("Size = %b, A = %d, DO = %h", Size, Address, DataOut);
            Address = Address + 4;
        end

    end

endmodule
