`include "TP_REGISTER_FILE.v"

module TP_REGISTER_FILE_tb;
    reg [31:0] PW;
    reg [4:0] RA, RB, RW;
    reg Clk, LE;
    wire [31:0] PA, PB;

    // Instanciando el módulo TP_REGISTER_FILE
    TP_REGISTER_FILE TPRF (
        .PA(PA),
        .PB(PB),
        .PW(PW),
        .RA(RA),
        .RB(RB),
        .RW(RW),
        .Clk(Clk),
        .LE(LE)
    );

    // Generador de reloj
    always #2 Clk = ~Clk;

    initial begin
        // Inicialización
        Clk = 0;
        LE = 1;
        PW = 20;
        RW = 0;
        RA = 0;
        RB = 31;

        // Monitor para imprimir valores en cada cambio de reloj
        $monitor("Time=%0t | RW=%d | RA=%d | RB=%d | PW=%d | PA=%d | PB=%d", $time, RW, RA, RB, PW, PA, PB);

        // Incrementar valores cada 4 unidades de tiempo
        repeat (31) begin
            #4;
            PW = PW + 1;
            RW = RW + 1;
            RA = RA + 1;
            RB = RB + 1;
        end

        // Cambiar valores de LE y PW, repetir la secuencia
        #4;
        LE = 0;
        PW = 55;

        repeat (31) begin
            #4;
            PW = PW + 1;
            RW = RW + 1;
            RA = RA + 1;
            RB = RB + 1;
        end

        #10;
        $finish;
    end
endmodule
