module image_tb();

    reg[6:0] row = 0;
    reg[6:0] col = 0;

    reg[6:0] rowW = 0;
    reg[6:0] colW = 0;

	//-- Registro para generar la señal de reloj
	reg clk = 0;
	//-- Generador de reloj. Periodo 2 unidades
	always #1 clk = ~clk;

	wire data;
	reg we, dataW;

	//-- Instanciar el componente (N=1 aqui, segundos)
	//automaton #(.WIDTH(WIDTH)) myCA ( .clk(clk), .data(data) );
	image image01 (
		.clk(clk),
		.row(row),
		.col(col),
		.data(data),
		.clkW(clk),
		.we(we),
		.rowW(rowW),
		.colW(colW),
		.dataW(dataW)
	);

	//-- Proceso al inicio
	initial begin

		//-- Fichero donde almacenar los resultados
		$dumpfile("image_tb.vcd");
		$dumpvars(0, image_tb);

		#2 begin
			we = 1'b1;
			rowW = 0;
			colW = 37;
			dataW = 1'b1;
		end

		for(row=0; row<5; row= row+1)
		begin
			$display("row: (%d)", row);
			for (col=35; col<=45; col=col+1)
			begin
				#2 // 2 so we have a full clock cycle (#1 is half a cycle)
				$display("data: %b (%d, %d)", data, row, col);
			end
		end
		# 1 $display("FIN de la simulacion");
		$finish;

	end

endmodule
