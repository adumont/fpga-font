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
       .clk(clk),                  // Input clock: 12MHz.

       .hsync(hsync0),             //  1, Horizontal sync out
       .vsync(vsync0),             //  1, Vertical sync out

       .x_px(px_x0),               // 10, X position for actual pixel
       .y_px(px_y0),               // 10, Y position for actual pixel
       .activevideo(activevideo0), //  1, Video active

       .px_clk(px_clk)             // Pixel clock
    );

    reg [1:0] zoom;
    `define ZoomCounter 2
    `define ZoomTexto   1

    // STAGE 1

    // buffer vga signals for 1 clock cycle 
    reg [9:0] px_x1, px_y1;
    reg [9:0] px_x2, px_y2;
    reg [9:0] px_x3, px_y3;
    reg hsync1, vsync1, activevideo1;
    reg hsync2, vsync2, activevideo2;
    reg hsync3, vsync3, activevideo3;
    reg [2:0] color2, color3;

    always @( posedge px_clk) begin
      { hsync1, vsync1, activevideo1, px_x1, px_y1 } <= { hsync0, vsync0, activevideo0, px_x0, px_y0 };
      { hsync2, vsync2, activevideo2, px_x2, px_y2 } <= { hsync1, vsync1, activevideo1, px_x1, px_y1 };
      { hsync3, vsync3, activevideo3, px_x3, px_y3 } <= { hsync2, vsync2, activevideo2, px_x2, px_y2 };
      color3 <= color2;
    end

    reg [`FONT_WIDTH-1:0] char_shown;

    wire [7:0] digit_ascii_code;
    reg  [3:0] hex_digit;

    nibble2digit nibble2digit0(hex_digit, digit_ascii_code);

    wire [7:0] char_texto;
    wire [9:0] texto_index_tmp = px_x2 >> (3+`ZoomTexto) ;

    texto texto0( texto_index_tmp[3:0] , char_texto);

    always @(*) begin
      char_shown = 8'h00;
      hex_digit = 4'b 0;
      char_shown = 8'b 0;
      color2 = `BLACK;

      if ( px_x2 >> (3+`ZoomCounter) == 10 && px_y2 >> (3+`ZoomCounter) ==  8  ) 
      begin
        hex_digit = counter[3:0];
        char_shown = digit_ascii_code;
        zoom = `ZoomCounter;
        color2 = `GREEN;
      end

      else if ( px_x2 >> (3+`ZoomCounter) ==  9 && px_y2 >> (3+`ZoomCounter) ==  8  )
      begin
        hex_digit = counter[7:4];
        char_shown = digit_ascii_code;
        zoom = `ZoomCounter;
        color2 = `GREEN;
      end

      else if ( px_x2 >> (3+`ZoomTexto) <= 5 && px_y2 >> (3+`ZoomTexto) ==  0  )
      begin
        char_shown = char_texto;
        zoom = `ZoomTexto;
        color2 = `WHITE;
      end

    end

    // STAGE 2

    // ouput wires
    wire font_bit;

    font font0 (
       .px_clk(px_clk),          // Pixel clock.
       .pos_x( px_x2 >> zoom ), // X screen position.
       .pos_y( px_y2 >> zoom ), // Y screen position.
       .character( char_shown ),  // Character at this pixel
       // output
       .data( font_bit )         // Output RGB stream.
    );

    // TODO: Embed in a combbin_to_ascii2ck
    // takes input: stream 3bin_to_ascii2
    // TODO: place register at the end to sync... (stream4)

    always @(*) begin
        rgb = `BLACK;
        if (activevideo3)
        begin
            if ( font_bit )
                rgb = color3;

            // Draw a border
            else if (px_y3 == 0 || px_y3 == 479 || px_x3 == 0 || px_x3 == 639 )
                rgb = `GREEN;

            else
                rgb = `BLACK;
        end
        else
            rgb = `BLACK;
    end

    assign hsync = hsync3;
    assign vsync = vsync3;

    wire endframe;
    assign endframe = ( px_x3 == 639 ) && ( px_y3 == 479 );

    // Register test.
    reg [7:0] framecounter = 8'h 00;  // Frame counter
    reg [7:0] counter = 8'h 00;   // Counter to show.

    // Register temporal test.
    always @(posedge endframe)
    begin
        framecounter <= framecounter + 1;
    end

    always @(posedge framecounter[2])
    begin
        counter <= counter + 1;
    end

endmodule

