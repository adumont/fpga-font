`default_nettype none
`include "const.vh"

module tilemem #(
        parameter ZOOM =  0
    ) (
        input wire        clk,
        input wire [25:0] RGBStr_i,
        output reg [`FONT_WIDTH-1:0] char_code
    );

    localparam cols = 80 / 2**ZOOM;
    localparam rows = 60 / 2**ZOOM;

    wire [9:0] px_x, px_y;
    assign px_x = RGBStr_i[`XC];
    assign px_y = RGBStr_i[`YC];

    wire [(13-2*ZOOM)-1:0] raddr;
    assign raddr = px_y[8:(3+ZOOM)] * 80 + px_x[9:(3+ZOOM)] ; // y (480) is 1 bit shorter than x (640)
    
    wire [`FONT_WIDTH-1:0] rdata;
    ram #( .ram_size( cols*rows ), .data_width( `FONT_WIDTH ) ) ram0 (
        .rclk( clk ),
        .raddr( raddr ),
        .dout( rdata ),
        .wclk( clk ),
        .write_en( 1'b0 ) // disable write port for now
    );
    defparam ram0.ROMFILE="ram65.list";

    // Registred output
    always @(posedge clk)
    begin
         char_code <= rdata;
    end

endmodule
