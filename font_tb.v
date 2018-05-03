module font_tb();

    reg[9:0] px_y = 0;
    reg[9:0] px_x = 0;

	//-- Registro para generar la señal de reloj
	reg clk = 0;
	//-- Generador de reloj. Periodo 2 unidades
	always #1 clk = ~clk;

	wire data;

	font fontRom01 (
        .px_clk(clk),
        .pos_x(px_x),       // X screen position.
        .pos_y(px_y),       // Y screen position.
        .character( 8'h 37 ),   // Character to stream.
        .data(data)     // Output RGB stream.
    );

	//-- Proceso al inicio
	initial begin

		//-- Fichero donde almacenar los resultados
		$dumpfile("font_tb.vcd");
		$dumpvars(0, font_tb);

		$write("             01234567\n");
		$write("             --------\n");

		#1
		for(px_y=0; px_y<8; px_y= px_y+1)
		begin
			$write("px_y: (%d) ", px_y);
			for (px_x=0; px_x<8; px_x=px_x+1)
			begin
				#2 // 2 so we have a full clock cycle (#1 is half a cycle)
				//$display("data: %b (%d, %d)", data, px_y, px_x);
				$write("%b", data);
			end
			$write("\n");
		end
		# 1 $display("FIN de la simulacion");
		$finish;

	end

endmodule
