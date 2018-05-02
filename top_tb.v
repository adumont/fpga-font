module top_tb();

	//-- Registro para generar la señal de reloj
	reg clk = 0;
	//-- Generador de reloj. Periodo 2 unidades
	always #1 clk = ~clk;

	top #( .N(1) ) uut ( .clk(clk)	);

	//-- Proceso al inicio
	initial begin

		//-- Fichero donde almacenar los resultados
		$dumpfile("top_tb.vcd");
		$dumpvars(0, top_tb);

		# 85 $display("FIN de la simulacion");
		$finish;

	end

endmodule
