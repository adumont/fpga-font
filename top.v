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

    reg [1:0] zoom = 0;
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


    // ---------------------------------------- //
    // vgaLabel1 (vgaModule)
    //

    wire       i_vgaLabel1_px_clk;
    wire [9:0] i_vgaLabel1_x;
    wire [9:0] i_vgaLabel1_y;
    wire       i_vgaLabel1_en;
    wire [7:0] o_vgaLabel1_addr;
    wire [7:0] i_vgaLabel1_din;
    wire [7:0] o_vgaLabel1_dout;
    wire [2:0] o_vgaLabel1_color;
    wire [1:0] o_vgaLabel1_zoom;
    wire       o_vgaLabel1_h2a;

    vgaModule vgaLabel1 (
      //---- input ports ----
      .px_clk(i_vgaLabel1_px_clk),
      .x     (i_vgaLabel1_x     ),
      .y     (i_vgaLabel1_y     ),
      .en    (i_vgaLabel1_en    ),
      .din   (i_vgaLabel1_din   ),
      //---- output ports ----
      .addr  (o_vgaLabel1_addr  ),
      .dout  (o_vgaLabel1_dout  ),
      .color (o_vgaLabel1_color ),
      .zoom  (o_vgaLabel1_zoom  ),
      .h2a   (o_vgaLabel1_h2a   )
    );
    // Define Parameters:
    defparam vgaLabel1.line   = 10;
    defparam vgaLabel1.col    = 20;
    defparam vgaLabel1.pzoom   = 0;
    defparam vgaLabel1.pcolor = `TEAL;
    defparam vgaLabel1.width  = 8;
    defparam vgaLabel1.height = 1;
    defparam vgaLabel1.offset = 0;
    // Connect Inputs:
    assign i_vgaLabel1_px_clk = px_clk ;
    assign i_vgaLabel1_x      = px_x0 ;
    assign i_vgaLabel1_y      = px_y0 ;
    assign i_vgaLabel1_en     = counter[0] ;
    assign i_vgaLabel1_din    = o_labelsRam_dout ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // vgaLabel2 (vgaModule)
    //
    wire       i_vgaLabel2_px_clk;
    wire [9:0] i_vgaLabel2_x;
    wire [9:0] i_vgaLabel2_y;
    wire       i_vgaLabel2_en;
    wire [7:0] o_vgaLabel2_addr;
    wire [7:0] i_vgaLabel2_din;
    wire [7:0] o_vgaLabel2_dout;
    wire [2:0] o_vgaLabel2_color;
    wire [1:0] o_vgaLabel2_zoom;
    wire       o_vgaLabel2_h2a;

    vgaModule vgaLabel2 (
      //---- input ports ----
      .px_clk(i_vgaLabel2_px_clk),
      .x     (i_vgaLabel2_x     ),
      .y     (i_vgaLabel2_y     ),
      .en    (i_vgaLabel2_en    ),
      .din   (i_vgaLabel2_din   ),
      //---- output ports ----
      .addr  (o_vgaLabel2_addr  ),
      .dout  (o_vgaLabel2_dout  ),
      .color (o_vgaLabel2_color ),
      .zoom  (o_vgaLabel2_zoom  ),
      .h2a   (o_vgaLabel2_h2a   )
    );
    // Define Parameters:
    defparam vgaLabel2.line   = 12;
    defparam vgaLabel2.col    = 5;
    defparam vgaLabel2.pzoom   = 0;
    defparam vgaLabel2.pcolor = `RED;
    defparam vgaLabel2.width  = 14;
    defparam vgaLabel2.height = 1;
    defparam vgaLabel2.offset = 8;
    // Connect Inputs:
    assign i_vgaLabel2_px_clk = px_clk ;
    assign i_vgaLabel2_x      = px_x0 ;
    assign i_vgaLabel2_y      = px_y0 ;
    assign i_vgaLabel2_en     = ~counter[0] ;
    assign i_vgaLabel2_din    = o_labelsRam_dout ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // vgaLabel3 (vgaModule)
    //
    wire       i_vgaLabel3_px_clk;
    wire [9:0] i_vgaLabel3_x;
    wire [9:0] i_vgaLabel3_y;
    wire       i_vgaLabel3_en;
    wire [7:0] o_vgaLabel3_addr;
    wire [7:0] i_vgaLabel3_din;
    wire [7:0] o_vgaLabel3_dout;
    wire [2:0] o_vgaLabel3_color;
    wire [1:0] o_vgaLabel3_zoom;
    wire       o_vgaLabel3_h2a;

    vgaModule vgaLabel3 (
      //---- input ports ----
      .px_clk(i_vgaLabel3_px_clk),
      .x     (i_vgaLabel3_x     ),
      .y     (i_vgaLabel3_y     ),
      .en    (i_vgaLabel3_en    ),
      .din   (i_vgaLabel3_din   ),
      //---- output ports ----
      .addr  (o_vgaLabel3_addr  ),
      .dout  (o_vgaLabel3_dout  ),
      .color (o_vgaLabel3_color ),
      .zoom  (o_vgaLabel3_zoom  ),
      .h2a   (o_vgaLabel3_h2a   )
    );
    // Define Parameters:
    defparam vgaLabel3.line   = 2;
    defparam vgaLabel3.col    = 2;
    defparam vgaLabel3.pzoom   = 1;
    defparam vgaLabel3.pcolor = `YELLOW;
    defparam vgaLabel3.width  = 6;
    defparam vgaLabel3.height = 1;
    defparam vgaLabel3.offset = 22;
    // Connect Inputs:
    assign i_vgaLabel3_px_clk = px_clk ;
    assign i_vgaLabel3_x      = px_x0 ;
    assign i_vgaLabel3_y      = px_y0 ;
    assign i_vgaLabel3_en     = 1'b 1 ;
    assign i_vgaLabel3_din    = o_labelsRam_dout ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // vgaRegister0 (vgaRegister)
    //

    wire       i_vgaRegister0_px_clk;
    wire [9:0] i_vgaRegister0_x;
    wire [9:0] i_vgaRegister0_y;
    wire       i_vgaRegister0_en;
    wire [7:0] o_vgaRegister0_addr;
    wire [7:0] i_vgaRegister0_din;
    wire [7:0] o_vgaRegister0_dout;
    wire [2:0] o_vgaRegister0_color;
    wire [1:0] o_vgaRegister0_zoom;
    wire       o_vgaRegister0_h2a;

    vgaRegister vgaRegister0 (
      //---- input ports ----
      .px_clk(i_vgaRegister0_px_clk),
      .x     (i_vgaRegister0_x     ),
      .y     (i_vgaRegister0_y     ),
      .en    (i_vgaRegister0_en    ),
      .din   (i_vgaRegister0_din   ),
      //---- output ports ----
      .addr  (o_vgaRegister0_addr  ),
      .dout  (o_vgaRegister0_dout  ),
      .color (o_vgaRegister0_color ),
      .zoom  (o_vgaRegister0_zoom  ),
      .h2a   (o_vgaRegister0_h2a   )
    );
    // Define Parameters:
    defparam vgaRegister0.line = 3;
    defparam vgaRegister0.col = 3;
    defparam vgaRegister0.pzoom = 3;
    defparam vgaRegister0.pcolor = `YELLOW;
    defparam vgaRegister0.width = 2;
    defparam vgaRegister0.height = 1;
    // defparam vgaRegister0.offset = ;
    // Connect Inputs:
    assign i_vgaRegister0_px_clk = px_clk ;
    assign i_vgaRegister0_x      = px_x0 ;
    assign i_vgaRegister0_y      = px_y0 ;
    assign i_vgaRegister0_en     = 1'b 1 ;
    assign i_vgaRegister0_din    = framecounter ;
    // ---------------------------------------- //


    // ---------------------------------------- //
    // labelsRam (ram)
    //
    wire         i_labelsRam_clk;
    wire [8-1:0] i_labelsRam_addr;
    wire         i_labelsRam_write_en;
    wire [8-1:0] i_labelsRam_din;
    wire [8-1:0] o_labelsRam_dout;

    ram labelsRam (
      //---- input ports ----
      .clk     (i_labelsRam_clk     ),
      .addr    (i_labelsRam_addr    ),
      .write_en(i_labelsRam_write_en),
      .din     (i_labelsRam_din     ),
      //---- output ports ----
      .dout    (o_labelsRam_dout    )
    );
    // Define Parameters:
    defparam labelsRam.addr_width = 8;
    defparam labelsRam.data_width = 8;
    defparam labelsRam.ROMFILE = "Labels.lst";
    // Connect Inputs:
    assign i_labelsRam_clk      = px_clk ;
    assign i_labelsRam_addr     = o_vgaLabel1_addr | o_vgaLabel2_addr | o_vgaLabel3_addr ; // we OR' all addresses. Only 1 should be valid, all others are 00.
    // we don't use write port here...
    assign i_labelsRam_write_en = 1'b 0 ;
    assign i_labelsRam_din      = 8'b 0 ;
    // ---------------------------------------- //

    reg [`FONT_WIDTH-1:0] char_shown;

    // ---------------------------------------- //
    // hex2asc0 (hex2asc)
    //
    wire [7:0] i_hex2asc0_din;
    wire       i_hex2asc0_h2a;
    wire [7:0] o_hex2asc0_dout;

    hex2asc hex2asc0 (
      //---- input ports ----
      .din (i_hex2asc0_din ),
      .h2a (i_hex2asc0_h2a ),
      //---- output ports ----
      .dout(o_hex2asc0_dout)
    );
    // Connect Inputs:
    assign i_hex2asc0_din  = o_vgaLabel1_dout  | o_vgaLabel2_dout  | o_vgaLabel3_dout | o_vgaRegister0_dout;
    assign i_hex2asc0_h2a  = o_vgaLabel1_h2a   | o_vgaLabel2_h2a   | o_vgaLabel3_h2a  | o_vgaRegister0_h2a;
    // ---------------------------------------- //

    wire [7:0] char_texto;
    wire [9:0] texto_index_tmp = px_x2 >> (3+`ZoomTexto) ;

    texto texto0( texto_index_tmp[3:0] , char_texto);

    always @(*) begin
      // char_shown = o_hex2asc0_dout ; // * Add all vgaBlocks here (bitwise OR)
      color2 = `BLACK | o_vgaLabel1_color | o_vgaLabel2_color | o_vgaLabel3_color | o_vgaRegister0_color; // * Add all vgaBlocks here (bitwise OR)
      zoom = o_vgaLabel1_zoom | o_vgaLabel2_zoom | o_vgaLabel3_zoom | o_vgaRegister0_zoom;

      // hex_digit = 4'b 0;

      // // TODO a "led" block (on/off, 0/1), that shows a single bit (~ led)

      // // TODO move to it's own vgaModule block
      // if ( px_x2 >> (3+`ZoomCounter) == 10 && px_y2 >> (3+`ZoomCounter) ==  8  ) 
      // begin
      //   hex_digit = counter[3:0];
      //   char_shown = digit_ascii_code;
      //   zoom = `ZoomCounter;
      //   color2 = `GREEN;
      // end

      // // TODO move to it's own vgaModule block (same as the previous one)
      // else if ( px_x2 >> (3+`ZoomCounter) ==  9 && px_y2 >> (3+`ZoomCounter) ==  8  )
      // begin
      //   hex_digit = counter[7:4];
      //   char_shown = digit_ascii_code;
      //   zoom = `ZoomCounter;
      //   color2 = `GREEN;
      // end

      // // TODO move to it's own vgaModule block
      // else if ( px_x2 >> (3+`ZoomTexto) <= 5 && px_y2 >> (3+`ZoomTexto) ==  0  )
      // begin
      //   char_shown = char_texto;
      //   zoom = `ZoomTexto;
      //   color2 = `WHITE;
      // end

    end

    // STAGE 2

    // ouput wires
    wire font_bit;

    font font0 (
       .px_clk(px_clk),          // Pixel clock.
       .pos_x( px_x2 >> zoom ), // X screen position.
       .pos_y( px_y2 >> zoom ), // Y screen position.
       .character( o_hex2asc0_dout ),  // Character at this pixel
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
            // TODO move to it's own vgaModule block
            else if (px_y3 == 0 || px_y3 == 479 || px_x3 == 0 || px_x3 == 639 )
                rgb = `GREEN;

            else  // TODO: remove this, unnecesarry
                rgb = `BLACK;
        end
        else  // TODO: remove this, unnecesarry
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

    always @(posedge framecounter[0])
    begin
        counter <= counter + 1;
    end

endmodule

