`default_nettype none

// check connections to VGA adapter on https://github.com/Obijuan/MonsterLED/wiki

module top (
        input  wire       clk,       // System clock.

        output wire       hsync1,     // Horizontal sync out signal
        output wire       vsync1,     // Vertical sync out signal
        output wire [2:0] rgb1,       // Red/Green/Blue VGA signal

        input  wire       sw1,    // board button 1
        input  wire       sw2,    // board button 2
        output wire [7:0] leds       // board leds
    );

    // avoid warning if we don't use led
    assign leds = 8'b 0100_0010;
    
    wire [7:0] character;
    assign character = 8'h 33;

    // Output signals from VGA sync
    wire px_clk;
    wire hsync0, vsync0, activevideo0;
    wire [9:0] px_x0, px_y0;

    // Instanciate 'vga_controller' module.
    vga_sync vga_sync0 (
        // input:
        .clk(clk),              // Input clock: 12MHz.
        
        // output:
        .hsync(hsync0),              //  1, Horizontal sync out
        .vsync(vsync0),              //  1, Vertical sync out

        .x_px(px_x0),                // 10, X position for actual pixel
        .y_px(px_y0),                // 10, Y position for actual pixel
        .activevideo(activevideo0),  //  1, Video active

        .px_clk(px_clk)            // Pixel clock
    );

    // Address alias in VGAstream 
    `define Active 0    //  1 bit
    `define VS 1        //  1 bit
    `define HS 2        //  1 bit
    `define YC 12:3     // 10 bits
    `define XC 22:13    // 10 bits
    `define R 23        //  1 bit
    `define G 24        //  1 bit
    `define B 25        //  1 bit
    `define VGA 22:0    // 23 bits
    `define RGB 25:23   //  3 bits

    `define Zoom 0

    // wire [`25:0] VGAstr0, VGAstr1;

    // buffer vga signals for 1 clock cyclevsync1
    wire activevideo1;
    wire [9:0] px_x1, px_y1;
    register #(.W(23)) reg1(
        .clk( px_clk ),
        .in(  {hsync0, vsync0, activevideo0, px_x0, px_y0 } ),
        .out( {hsync1, vsync1, activevideo1, px_x1, px_y1 } )
    );

    wire pixel_on1;

    font font0 (
        .px_clk(px_clk),      // Pixel clock.
        .pos_x(px_x0 >> `Zoom),       // X screen position.
        .pos_y(px_y0 >> `Zoom),       // Y screen position.
        .character( (px_x0 >> `Zoom) >> 3 ),   // Character to stream.
        .data(pixel_on1)     // Output RGB stream.
    );

/*     // Tile memory
    tilemem tilemem0 (
        .px_clk(px_clk),          // Pixel clock
        .pos_x((px_x0 >> `Zoom) >> 3),   // X screen position --> we'll compute the tile x,y
        .pos_y((px_y0 >> `Zoom) >> 3),   // Y screen position.
        .character(pixel_on1)     // Output --> Char code [0..255]
    );
 */

    assign rgb1 = ( activevideo1 
                    && px_y1[9:3] >> `Zoom < 7'd 16
                    //&& px_x1[9:3] >> `Zoom < 7'd 16
                ) ? { pixel_on1, pixel_on1, pixel_on1 } : 3'b000;

endmodule
