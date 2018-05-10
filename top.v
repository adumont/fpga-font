`default_nettype none
`include "const.vh"

// check connections to VGA adapter on https://github.com/Obijuan/MonsterLED/wiki

module top (
        input  wire       clk,       // System clock.

        output wire       hsync,     // Horizontal sync out signal
        output wire       vsync,     // Vertical sync out signal
        output reg  [2:0] rgb,       // Red/Green/Blue VGA signal

        input  wire       sw1,    // board button 1
        input  wire       sw2,    // board button 2
        output wire [7:0] leds       // board leds
    );

    // avoid warning if we don't use led
    assign leds = 8'b 0100_0010;
    
    // Output signals from vga_sync0
    wire px_clk;
    wire hsync0, vsync0, activevideo0;
    wire [9:0] px_x0, px_y0;

    // Instanciate 'vga_sync' module.
    vga_sync vga_sync0 (
    /*  in */ .clk(clk),                  // Input clock: 12MHz.

    /* out */ .hsync(hsync0),             //  1, Horizontal sync out
    /* out */ .vsync(vsync0),             //  1, Vertical sync out
    /* out */ .x_px(px_x0),               // 10, X position for actual pixel
    /* out */ .y_px(px_y0),               // 10, Y position for actual pixel
    /* out */ .activevideo(activevideo0), //  1, Video active

    /* out */ .px_clk(px_clk)             // Pixel clock
    );

    `define Zoom 0

    // STAGE 1

    // buffer vga signals for 1 clock cycle 
    reg [9:0] px_x1, px_y1;
    reg [9:0] px_x2, px_y2;
    reg [9:0] px_x3, px_y3;
    reg hsync1, vsync1, activevideo1;
    reg hsync2, vsync2, activevideo2;
    reg hsync3, vsync3, activevideo3;

    wire [25:0] RGBStr0;
    reg  [25:0] RGBStr1, RGBStr2, RGBStr3;

    assign RGBStr0 = { 3'b000, px_x0, px_y0, hsync0, vsync0, activevideo0 };

    always @( posedge px_clk) begin
      { hsync1, vsync1, activevideo1, px_x1, px_y1 } <= { hsync0, vsync0, activevideo0, px_x0, px_y0 };
      { hsync2, vsync2, activevideo2, px_x2, px_y2 } <= { hsync1, vsync1, activevideo1, px_x1, px_y1 };
      { hsync3, vsync3, activevideo3, px_x3, px_y3 } <= { hsync2, vsync2, activevideo2, px_x2, px_y2 };
      
      RGBStr1 <= RGBStr0;
      RGBStr2 <= RGBStr1;
      RGBStr3 <= RGBStr2;
    end



    /* TODO tilemem0
        - change addressing scheme to optime for low BRAM resources on the iCE40hx-1k
    */    

    // ouput wires
    wire [`FONT_WIDTH-1:0] char_code;

    tilemem #( .ZOOM( `Zoom ) ) tilemem0 (
    /*  in */ .clk( px_clk ),
    /*  in */ .RGBStr_i( RGBStr0 ),
    /* out */ .char_code( char_code )
    );

    // STAGE 2

    // ouput wires
    wire font_bit;


    /* TODO font0
        - coger en input RGBStr2
        - separar font y meterle un rom.v dentro
    */    
    font font0 (
    /*  in */  .px_clk(px_clk),          // Pixel clock.
    /*  in */  .pos_x( px_x2 >> `Zoom ), // X screen position.
    /*  in */  .pos_y( px_y2 >> `Zoom ), // Y screen position.
    /*  in */  .character( char_code ),  // Character at this pixel
    /* out */  .data( font_bit )         // Output RGB stream.
    );

    // TODO: Embed in a combination block
    // takes input: stream 3
    // TODO: place register at the end to sync... (stream4)

    always @(*) begin
        rgb <= 3'b000;
        if (activevideo3) begin
            if ( font_bit )
                rgb <= 3'b010;
            else if (px_y3 == 0 || px_y3 == 479 || px_x3 == 0 || px_x3 == 639 )
                rgb <= 3'b001;
            else
                rgb <= 3'b000;
        end
        else
            rgb <= 3'b000;
    end

    assign hsync = hsync3;
    assign vsync = vsync3;
endmodule
