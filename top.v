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

    `define Zoom 2

    // STAGE 1

    // buffer vga signals for 1 clock cycle 
    reg [9:0] px_x1, px_y1;
    reg [9:0] px_x2, px_y2;
    reg [9:0] px_x3, px_y3;
    reg hsync1, vsync1, activevideo1;
    reg hsync2, vsync2, activevideo2;
    reg hsync3, vsync3, activevideo3;
    reg activevideo4;

    always @( posedge px_clk) begin
      { hsync1, vsync1, activevideo1, px_x1, px_y1 } <= { hsync0, vsync0, activevideo0, px_x0, px_y0 };
      { hsync2, vsync2, activevideo2, px_x2, px_y2 } <= { hsync1, vsync1, activevideo1, px_x1, px_y1 };
      { hsync3, vsync3, activevideo3, px_x3, px_y3 } <= { hsync2, vsync2, activevideo2, px_x2, px_y2 };
      activevideo4 <= activevideo3;
    end

    reg [`FONT_WIDTH-1:0] char_shown;

    wire [7:0] digit_ascii_code;
    reg  [3:0] hex_digit;

    hex_to_ascii_digit hex_to_ascii_digit0(hex_digit, digit_ascii_code);

    always @(*) begin
      char_shown = 8'h00;
      if (activevideo2) begin

        if ( px_x2 >> (3+`Zoom) == 10 && px_y2 >> (3+`Zoom) ==  8  ) 
        begin
          hex_digit = counter[3:0];
          char_shown = digit_ascii_code;
        end

        else if ( px_x2 >> (3+`Zoom) ==  9 && px_y2 >> (3+`Zoom) ==  8  )
        begin
          hex_digit = counter[7:4];
          char_shown = digit_ascii_code;
        end

      end
    end

    // STAGE 2

    // ouput wires
    wire font_bit;

    font font0 (
    /*  in */  .px_clk(px_clk),          // Pixel clock.
    /*  in */  .pos_x( px_x2 >> `Zoom ), // X screen position.
    /*  in */  .pos_y( px_y2 >> `Zoom ), // Y screen position.
    /*  in */  .character( char_shown ),  // Character at this pixel
    /* out */  .data( font_bit )         // Output RGB stream.
    );

    // TODO: Embed in a combbin_to_ascii2ck
    // takes input: stream 3bin_to_ascii2
    // TODO: place register at the end to sync... (stream4)

    always @(*) begin
        rgb = 3'b000;
        if (activevideo3) begin
            if ( font_bit )
                rgb = counter[2:0] == 3'b0 ? 3'b010 : counter[2:0];
            else if (px_y3 < 5 || px_y3 > 474 || px_x3 < 5 || px_x3 > 634 )
                rgb = 3'b001;
//          else if ( px_y2 >> (3+`Zoom) ==  8 )
//              rgb = 3'b111;
            else
                rgb = 3'b000;
        end
        else
            rgb = 3'b000;
    end

    assign hsync = hsync3;
    assign vsync = vsync3;


    // clock divider
    wire clk_counter;
    divM #( 12_000_000/16 ) div_clk_counter(
        .clk_in(clk),
        .clk_out(clk_counter)
    );

    reg [7:0] counter = 0;
    always @( posedge clk_counter )
        counter <= counter + 1;

endmodule

module hex_to_ascii_digit(hex_digit, ascii_code);
    input [3:0] hex_digit;
    output reg [7:0] ascii_code;

    always @(*)
        case (hex_digit)
            4'h0: ascii_code = 8'h30;
            4'h1: ascii_code = 8'h31;
            4'h2: ascii_code = 8'h32;
            4'h3: ascii_code = 8'h33;
            4'h4: ascii_code = 8'h34;
            4'h5: ascii_code = 8'h35;
            4'h6: ascii_code = 8'h36;
            4'h7: ascii_code = 8'h37;
            4'h8: ascii_code = 8'h38;
            4'h9: ascii_code = 8'h39;
            4'hA: ascii_code = 8'h41;
            4'hB: ascii_code = 8'h42;
            4'hC: ascii_code = 8'h43;
            4'hD: ascii_code = 8'h44;
            4'hE: ascii_code = 8'h45;
            4'hF: ascii_code = 8'h46;
            default: ascii_code = 8'h00;
        endcase
endmodule
