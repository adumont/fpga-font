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

    `include "functions.vh"

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

    wire [`stream] vga_str0 = { {`vpart2_w {1'b 0}}, px_y0, px_x0, vsync0, hsync0 };

    // reg [1:0] zoom = 0;
    // `define ZoomCounter 2
    // `define ZoomTexto   1

    // // STAGE 1

    // // buffer vga signals for 1 clock cycle 
    // reg [9:0] px_x1, px_y1;
    // reg [9:0] px_x2, px_y2;
    // reg [9:0] px_x3, px_y3;
    // reg hsync1, vsync1, activevideo1;
    // reg hsync2, vsync2, activevideo2;
    // reg hsync3, vsync3, activevideo3;
    // reg [2:0] color2, color3;

    // always @( posedge px_clk) begin
    //   { hsync1, vsync1, activevideo1, px_x1, px_y1 } <= { hsync0, vsync0, activevideo0, px_x0, px_y0 };
    //   { hsync2, vsync2, activevideo2, px_x2, px_y2 } <= { hsync1, vsync1, activevideo1, px_x1, px_y1 };
    //   { hsync3, vsync3, activevideo3, px_x3, px_y3 } <= { hsync2, vsync2, activevideo2, px_x2, px_y2 };
    //   color3 <= color2;
    // end

    // ---------------------------------------- //
    // vgaLabel1 (vgaModule)
    //
    wire           i_vgaLabel1_px_clk;
    wire [`stream] i_vgaLabel1_in;
    wire           i_vgaLabel1_en;
    wire [`stream] o_vgaLabel1_out;

    vgaModule vgaLabel1 (
      //---- input ports ----
      .px_clk(i_vgaLabel1_px_clk),
      .in    (i_vgaLabel1_in    ),
      .en    (i_vgaLabel1_en    ),
      //---- output ports ----
      .out   (o_vgaLabel1_out   )
    );
    // Define Parameters:
    defparam vgaLabel1.line   = 7'd 10;
    defparam vgaLabel1.col    = 7'd 20;
    defparam vgaLabel1.pzoom  = `zm_w'b 0;
    defparam vgaLabel1.pcolor = `TEAL;
    defparam vgaLabel1.width  = 8;
    defparam vgaLabel1.offset = 8'd 60;
    // Connect Inputs:
    assign i_vgaLabel1_px_clk = px_clk ;
    assign i_vgaLabel1_in     = vga_str0;
    assign i_vgaLabel1_en     = 1'b 1  ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // vgaLabel2 (vgaModule)
    //
    wire           i_vgaLabel2_px_clk;
    wire [`stream] i_vgaLabel2_in;
    wire           i_vgaLabel2_en;
    wire [`stream] o_vgaLabel2_out;

    vgaModule vgaLabel2 (
      //---- input ports ----
      .px_clk(i_vgaLabel2_px_clk),
      .in    (i_vgaLabel2_in    ),
      .en    (i_vgaLabel2_en    ),
      //---- output ports ----
      .out   (o_vgaLabel2_out   )
    );
    // Define Parameters:
    defparam vgaLabel2.line   = 12;
    defparam vgaLabel2.col    = 5;
    defparam vgaLabel2.pzoom  = `zm_w'b 0;
    defparam vgaLabel2.pcolor = `RED;
    defparam vgaLabel2.width  = 25;
    defparam vgaLabel2.offset = 8'd 28;
    // Connect Inputs:
    assign i_vgaLabel2_px_clk = px_clk ;
    assign i_vgaLabel2_in     = o_vgaLabel1_out ;
    assign i_vgaLabel2_en     = 1'b 1 ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // vgaLabel3 (vgaModule)
    //
    wire           i_vgaLabel3_px_clk;
    wire [`stream] i_vgaLabel3_in;
    wire           i_vgaLabel3_en;
    wire [`stream] o_vgaLabel3_out;

    vgaModule vgaLabel3 (
      //---- input ports ----
      .px_clk(i_vgaLabel3_px_clk),
      .in    (i_vgaLabel3_in    ),
      .en    (i_vgaLabel3_en    ),
      //---- output ports ----
      .out   (o_vgaLabel3_out   )
    );
    // Define Parameters:
    defparam vgaLabel3.line   = 2;
    defparam vgaLabel3.col    = 2;
    defparam vgaLabel3.pzoom  = `zm_w'b 1;
    defparam vgaLabel3.pcolor = `YELLOW;
    defparam vgaLabel3.width  = 6;
    defparam vgaLabel3.offset = 8'd 22;
    // Connect Inputs:
    assign i_vgaLabel3_px_clk = px_clk ;
    assign i_vgaLabel3_in     = o_vgaLabel2_out ;
    assign i_vgaLabel3_en     = 1 ;
    // ---------------------------------------- //

    // // ---------------------------------------- //
    // // vgaRegister0 (vgaRegister)
    // //

    // wire       i_vgaRegister0_px_clk;
    // wire [9:0] i_vgaRegister0_x;
    // wire [9:0] i_vgaRegister0_y;
    // wire       i_vgaRegister0_en;
    // wire [7:0] o_vgaRegister0_addr;
    // wire [7:0] i_vgaRegister0_din;
    // wire [7:0] o_vgaRegister0_dout;
    // wire [2:0] o_vgaRegister0_color;
    // wire [1:0] o_vgaRegister0_zoom;
    // wire       o_vgaRegister0_h2a;

    // vgaRegister vgaRegister0 (
    //   //---- input ports ----
    //   .px_clk(i_vgaRegister0_px_clk),
    //   .x     (i_vgaRegister0_x     ),
    //   .y     (i_vgaRegister0_y     ),
    //   .en    (i_vgaRegister0_en    ),
    //   .din   (i_vgaRegister0_din   ),
    //   //---- output ports ----
    //   .addr  (o_vgaRegister0_addr  ),
    //   .dout  (o_vgaRegister0_dout  ),
    //   .color (o_vgaRegister0_color ),
    //   .zoom  (o_vgaRegister0_zoom  ),
    //   .h2a   (o_vgaRegister0_h2a   )
    // );
    // // Define Parameters:
    // defparam vgaRegister0.line = 3;
    // defparam vgaRegister0.col = 3;
    // defparam vgaRegister0.pzoom = 3;
    // defparam vgaRegister0.pcolor = `YELLOW;
    // defparam vgaRegister0.width = 2;
    // defparam vgaRegister0.height = 1;
    // // defparam vgaRegister0.offset = ;
    // // Connect Inputs:
    // assign i_vgaRegister0_px_clk = px_clk ;
    // assign i_vgaRegister0_x      = px_x0 ;
    // assign i_vgaRegister0_y      = px_y0 ;
    // assign i_vgaRegister0_en     = 1'b 1 ;
    // assign i_vgaRegister0_din    = framecounter ;
    // // ---------------------------------------- //


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
    assign i_labelsRam_addr     = o_vgaLabel3_out[`addr_s +: 8]; // FIX THIS +:8 --> chip select & ADDR
    // we don't use write port here...
    assign i_labelsRam_write_en = 1'b 0 ;
    assign i_labelsRam_din      = 8'b 0 ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // reg0 (register)
    //

    wire                         i_reg0_clk;
    wire [`stream_w-`addr_w-1:0] i_reg0_in;
    wire [`stream_w-`addr_w-1:0] o_reg0_out;

    register reg0 (
      //---- input ports ----
      .clk(i_reg0_clk),
      .in (i_reg0_in ),
      //---- output ports ----
      .out(o_reg0_out)
    );
    // Define Parameters:
    defparam reg0.w = `stream_w-`addr_w;
    // Connect Inputs:
    assign i_reg0_clk = px_clk ;
    assign i_reg0_in  = o_vgaLabel3_out[0 +: `addr_s];
    // ---------------------------------------- //

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
    assign i_hex2asc0_din  = o_labelsRam_dout;
    assign i_hex2asc0_h2a  = o_reg0_out[`ha];
    // ---------------------------------------- //

    // ---------------------------------------- //
    // font0 (font)
    //
    wire       i_font0_px_clk;
    wire [9:0] i_font0_pos_x;
    wire [9:0] i_font0_pos_y;
    wire [7:0] i_font0_character;
    wire       o_font0_data;

    font font0 (
      //---- input ports ----
      .px_clk   (i_font0_px_clk   ),
      .pos_x    (i_font0_pos_x    ),
      .pos_y    (i_font0_pos_y    ),
      .character(i_font0_character),
      //---- output ports ----
      .data     (o_font0_data     )
    );
    // Define Parameters:
    defparam font0.FILE_FONT = "font_rom.hex";
    // Connect Inputs:
    assign i_font0_px_clk    = px_clk ;
    assign i_font0_pos_x     = o_reg0_out[`xc]>>o_reg0_out[`zm];
    assign i_font0_pos_y     = o_reg0_out[`yc]>>o_reg0_out[`zm] ;
    assign i_font0_character = o_hex2asc0_dout ;
    // ---------------------------------------- //


    // ---------------------------------------- //
    // reg1 (register)
    //
    wire             i_reg1_clk;
    wire [`zm_s-1:0] i_reg1_in;
    wire [`zm_s-1:0] o_reg1_out;

    register reg1 (
      //---- input ports ----
      .clk(i_reg1_clk),
      .in (i_reg1_in ),
      //---- output ports ----
      .out(o_reg1_out)
    );
    // Define Parameters:
    defparam reg1.w = `zm_s;
    // Connect Inputs:
    assign i_reg1_clk = px_clk ;
    assign i_reg1_in  = o_reg0_out[0 +: `zm_s] ;
    // ---------------------------------------- //


    // TODO rename these wires
    wire [`xc_w-1:0] px_x3 = o_reg1_out[`xc] ;
    wire [`yc_w-1:0] px_y3 = o_reg1_out[`yc] ;
    wire [`fg_w-1:0] fg    = o_reg1_out[`fg] ;
    wire [`bg_w-1:0] bg    = o_reg1_out[`bg] ;

    always @(*) begin
        rgb = bg; // background color
        if ( o_font0_data )
          rgb = fg;

        // Draw a border
        // TODO move to it's own vgaModule block
        else if (px_y3 == 0 || px_y3 == 479 || px_x3 == 0 || px_x3 == 639 )
          rgb = `GREEN;
      
        else
          rgb = o_reg1_out[`bg]; // background color
    end

    assign hsync = o_reg1_out[`hs];
    assign vsync = o_reg1_out[`vs];


    wire endframe = ( o_reg1_out[`xc] == 639 ) && ( o_reg1_out[`yc] == 479 );

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

