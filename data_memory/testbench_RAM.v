`include "RAM.v"

module RAM_tb;
    wire [31:0] DataOut;
    reg Enable, ReadWrite;
    reg [7:0] Address; 
    reg [31:0] DataIn;
    reg [1:0] Size;

    // Instancia de la RAM
    ram256x8 ram1 (
        .DataOut(DataOut), 
        .Enable(Enable), 
        .ReadWrite(ReadWrite), 
        .Address(Address), 
        .DataIn(DataIn), 
        .Size(Size)
    );

    // Testbench del RAM 
    initial begin

        // Leer un word de las localizaciones 0, 4, 8 y 12
        Size = 2'b10;     // Word (32-bit)
        Address = 8'b0;   // Starting address
        Enable = 1'b1;    // Enabled
        ReadWrite = 1'b0; // Read/write disabled

        $display("\nReading words from locations 0, 4, 8, and 12:");
        repeat (4) begin
            #1;
            $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
            Address = Address + 4;
        end

        // Leer bytes y halfwords
        $display("\nReading bytes from 0 and 3 & halfwords from 4 and 6:");
        Address = 8'd0; Size = 2'b00; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
        Address = 8'd3; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
        Address = 8'd4; Size = 2'b01; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
        Address = 8'd6; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);

        // Writing on memory
        Enable = 1'b1;    // Enabled
        ReadWrite = 1'b1; // Read/write enabled
        $display("\nWriting data to memory...");

        Size = 2'b00; // Write as byte
        Address = 8'd0; DataIn = 32'hA6; #1;
        Address = 8'd2; DataIn = 32'hDD; #1;

        Size = 2'b01; // Write as halfword
        Address = 8'd4; DataIn = 32'hABCD; #1;
        Address = 8'd6; DataIn = 32'hEF01; #1;

        Size = 2'b10; // Write as word
        Address = 8'd12; DataIn = 32'h33445566; #1;

        // Read word from 0, 4 y 12
        Enable = 1'b1;     // Enabled
        ReadWrite = 1'b0;  // Read/write disabled
        Size = 2'b10;

        $display("\nReading words from locations 0, 4, and 12:");
        Address = 8'd0; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
        Address = 8'd4; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);
        Address = 8'd12; #1;
        $display("A = %d, DO = %h, Size = %b, RW = %b, E = %b", Address, DataOut, Size, ReadWrite, Enable);

        #1 $finish;
    end

endmodule
