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
    assign character = 0;

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

    // buffer vga signals for 1 clock cycle
    wire activevideo1;
    wire [9:0] px_x1, px_y1;
    register #(.W(23)) reg1(
        .clk( px_clk ),
        .in(  {hsync0, vsync0, activevideo0, px_x0, px_y0 } ),
        .out( {hsync1, vsync1, activevideo1, px_x1, px_y1 } )
    );

    wire pixel_on1;

    font fontRom01 (
        .px_clk(px_clk),      // Pixel clock.
        .pos_x(px_x0),       // X screen position.
        .pos_y(px_y0),       // Y screen position.
        .character( character ),   // Character to stream.
        .data(pixel_on1)     // Output RGB stream.
    );

// && px_x0[9:3]==7'd 4

    assign rgb1 = ( activevideo1 
                    && px_y1[9:3]==7'd 10
                    && px_x1[9:3]== 7'd 10
                ) ? { pixel_on1, pixel_on1, pixel_on1 } : 3'b000;

endmodule
