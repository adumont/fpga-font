module top_tb();

	//-- Registro para generar la señal de reloj
	reg clk = 0;
	//-- Generador de reloj. Periodo 2 unidades
	always #1 clk = ~clk;

	wire       hsync;     // Horizontal sync out signal
	wire       vsync;     // Vertical sync out signal
	wire [2:0] rgb;       // Red/Green/Blue VGA signal

	reg       sw1;    // board button 1
	reg       sw2;    // board button 2
	wire [7:0] leds;       // board leds

	// top #( .N(1) ) uut ( .clk(clk)	);
	top top0 (
		.clk(clk),
		.hsync(hsync),
		.vsync(vsync),
		.rgb(rgb),
		.sw1(sw1),
		.sw2(sw2),
		.leds(leds)
	);

	//-- Proceso al inicio
	initial begin

		//-- Fichero donde almacenar los resultados
		$dumpfile("top_tb.vcd");
		$dumpvars(0, top_tb);

		# 700000 $display("FIN de la simulacion");
		$finish;

	end

endmodule
