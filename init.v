//-- init.v  (version optimizada)
module init(input wire clk, output reg ini);
    //-- Registro de 1 bit inicializa a 0 (solo para simulacion)
    //-- Al sintetizarlo siempre estará a cero con independencia
    //-- del valor al que lo pongamos
    reg ini = 0;

    //-- En flanco de subida sacamos un "1" por la salida
    always @(posedge(clk))
        ini <= 1;

endmodule
