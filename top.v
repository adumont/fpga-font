`default_nettype none

// check connections to VGA adapter on https://github.com/Obijuan/MonsterLED/wiki

module top (
            input  wire       clk,       // System clock.

            output wire       hsync,     // Horizontal sync out signal (pin 13 male monitor).
            output wire       vsync,     // Vertical sync out signal (pin 14 male monitor).
            output wire [2:0] rgb,       // Red/Green/Blue VGA signal (pin 1 male monitor).

            input  wire       sw1,       // board switch 1
            input  wire       sw2,       // board switch 2
            output wire [7:0] leds       // board leds
        );

    // avoid warning if we don't use led
    assign leds = 8'b 0100_0010;
    
    // wires for current pixel
    wire [9:0] x, y;

    wire [7:0] character;
    assign character = 0;

    // Signals from VGA controller.
    wire activevideo;
    wire px_clk;

    // Instanciate 'vga_controller' module.
    vga_sync vga_sync0 (
        // input:
        .clk(clk),              // Input clock: 12MHz.
        
        // output:
        .hsync(hsync),            // Horizontal sync out
        .vsync(vsync),            // Vertical sync out

        .x_px(x),             // X position for actual pixel
        .y_px(y),             // Y position for actual pixel
        .activevideo(activevideo),      // Video active

        .px_clk(px_clk)            // Pixel clock
    );

    wire pixel_on;

    font fontRom01 (
        .px_clk(px_clk),      // Pixel clock.
        .pos_x(x),       // X screen position.
        .pos_y(y),       // Y screen position.
        .character( character ),   // Character to stream.
        .data(pixel_on)     // Output RGB stream.
    );

// && x[9:3]==7'd 4

    assign rgb = ( activevideo && y[9:3]==7'd 10 && x[9:3]== 7'd 10 ) ? {pixel_on,pixel_on,pixel_on} : 3'b000;

endmodule
