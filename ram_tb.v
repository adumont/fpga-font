module ram_tb();

    reg[6:0] x_px = 0;
    wire [7:0] rdata;

	//-- Registro para generar la señal de reloj
	reg clk = 0;
	//-- Generador de reloj. Periodo 2 unidades
	always #1 clk = ~clk;

    ram #( .Zoom(0) ) ram0 (
        .rclk( clk ),
        .raddr( x_px ),
        .dout( rdata ),
        .wclk( clk ),
        .write_en( 1'b0 ) // disable write port for now
    );
    defparam ram0.addr_width = 7; // only 1 line
    defparam ram0.data_width = 8; // 256 ASCII code

	//-- Proceso al inicio
	initial begin

		//-- Fichero donde almacenar los resultados
		$dumpfile("ram_tb.vcd");
		$dumpvars(0, ram_tb);

		for(x_px=0; x_px<80; x_px= x_px+1)
        begin
			#2 $display(x_px, rdata);
            //$display("x_px: (%d), ", x_px);
        end

        #10
        $finish;

	end


endmodule
