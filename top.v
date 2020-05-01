`default_nettype none
`include "const.vh"

// check connections to VGA adapter on https://github.com/Obijuan/MonsterLED/wiki

module top (
        input  wire       clk,       // System clock.

        input  wire       RX,
        output wire       TX,

        output wire       hsync,     // Horizontal sync out signal
        output wire       vsync,     // Vertical sync out signal
        output reg  [2:0] rgb,       // Red/Green/Blue VGA signal

        input  wire       sw1,    // board button 1
        input  wire       sw2,    // board button 2
        output wire [7:0] leds       // board leds
    );

    //`ifdef BOARD_HAVE_BUTTONS
    wire sw1_d; // pulse when sw pressed
    wire sw1_u; // pulse when sw released
    wire sw1_s; // sw state
    debouncer db_sw1 (.clk(clk), .PB(sw1), .PB_down(sw1_d), .PB_up(sw1_u), .PB_state(sw1_s));
    //`endif

    `include "functions.vh"

    localparam def_bg = `BLACK; // default background color
    localparam baudsDivider=24'd104;

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

    wire [`stream] vga_str0 = { {`vpart2_w {1'b 0}}, activevideo0, px_y0, px_x0, vsync0, hsync0 };

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
    // vgaInbox (vgaWord)
    //

    wire           i_vgaInbox_px_clk;
    wire [`stream] i_vgaInbox_in;
    wire           i_vgaInbox_en;
    wire [`stream] o_vgaInbox_out;

    vgaWord vgaInbox (
      //---- input ports ----
      .px_clk(i_vgaInbox_px_clk),
      .in    (i_vgaInbox_in    ),
      .en    (i_vgaInbox_en    ),
      //---- output ports ----
      .out   (o_vgaInbox_out   )
    );
    // Define Parameters:
    defparam vgaInbox.line = 20;
    defparam vgaInbox.col = 0;
    defparam vgaInbox.pzoom = `zm_w'b 0;
    defparam vgaInbox.pcolor = `WHITE;
    defparam vgaInbox.width = 64;
    // Connect Inputs:
    assign i_vgaInbox_px_clk = px_clk ;
    assign i_vgaInbox_in     = o_vgaLabel2_out ;
    assign i_vgaInbox_en     = 1 ;
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
    assign i_vgaLabel3_in     = o_vgaInbox_out ;
    assign i_vgaLabel3_en     = 1 ;
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
    assign i_labelsRam_addr     = o_vgaLabel3_out[`addr]; // ADDR
    // we don't use write port here...
    assign i_labelsRam_write_en = 1'b 0 ;
    assign i_labelsRam_din      = 8'b 0 ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // reg0 (register)
    //

    wire               i_reg0_clk;
    wire [`addr_s-1:0] i_reg0_in;  // we keep from bit 0 up-
    wire [`addr_s-1:0] o_reg0_out; // -to `cs_s not included

    register reg0 (
      //---- input ports ----
      .clk(i_reg0_clk),
      .in (i_reg0_in ),
      //---- output ports ----
      .out(o_reg0_out)
    );
    // Define Parameters:
    defparam reg0.w = `addr_s;
    // Connect Inputs:
    assign i_reg0_clk = px_clk ;
    assign i_reg0_in  = o_vgaLabel3_out[0 +: `addr_s];
    // ---------------------------------------- //


    // ---------------------------------------- //
    // ramMux (combinational block)
    //

    // we Mux the ram's output & valid signals 
    // and only select the correct one, depending
    // on chip-select (cs)

    reg [7:0] o_ramMux_dout;
    reg       o_ramMux_valid;

    always @(*)
    begin
      case( o_reg0_out[`cs] )
        `cs_w'd 0: { o_ramMux_valid, o_ramMux_dout } = { 1'b 1, o_labelsRam_dout } ; // Label RAM, cs = 0
        `cs_w'd 1: { o_ramMux_valid, o_ramMux_dout } = { INBOX_o_dmp_valid, INBOX_o_dmp_data }; // INBOX, cs = 1
        default: { o_ramMux_valid, o_ramMux_dout } = { 1'b 1, 8'h00 };
      endcase
    end
    // ---------------------------------------- //

    // ---------------------------------------- //
    // hex2asc0 (hex2asc)
    //
    wire [7:0] i_hex2asc0_din;
    wire       i_hex2asc0_h2a;
    wire       i_hex2asc0_nb ;
    wire [7:0] o_hex2asc0_dout;

    hex2asc hex2asc0 (
      //---- input ports ----
      .din (i_hex2asc0_din ),
      .h2a (i_hex2asc0_h2a ),
      .nb  (i_hex2asc0_nb  ),
      //---- output ports ----
      .dout(o_hex2asc0_dout)
    );
    // Connect Inputs:
    assign i_hex2asc0_din  = o_ramMux_dout;
    assign i_hex2asc0_nb   = o_reg0_out[`nb];
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
    // we concat the signals, from bit 0 up to zm (excluded)
    // and the valid signal (out of the ramMux)

    wire                        i_reg1_clk;
    wire [`valid_w + `zm_s-1:0] i_reg1_in;
    wire [`valid_w + `zm_s-1:0] o_reg1_out;

    register reg1 (
      //---- input ports ----
      .clk(i_reg1_clk),
      .in (i_reg1_in ),
      //---- output ports ----
      .out(o_reg1_out)
    );
    // Define Parameters:
    defparam reg1.w = 1 + `zm_s;
    // Connect Inputs:
    assign i_reg1_clk = px_clk ;
    assign i_reg1_in  = { o_ramMux_valid, o_reg0_out[0 +: `zm_s] } ;
    // ---------------------------------------- //

    wire [`valid_w + `zm_s-1:0] result_stream= o_reg1_out; // we only reference this once, here, easier if we need to modify

    // TODO rename these wires x3, y3, activivideo3 (also in GUI)
    wire [`xc_w-1:0] px_x3        = result_stream[`xc] ;
    wire [`yc_w-1:0] px_y3        = result_stream[`yc] ;
    wire [`ab_w-1:0] ab           = result_stream[`ab] ;
    wire [`fg_w-1:0] fg           = result_stream[`fg] ;
    wire [`bg_w-1:0] bg           = result_stream[`bg] ;
    wire [`av_w-1:0] activevideo3 = result_stream[`av] ;
    wire             valid        = result_stream[`valid] ;

    // top module outputs
    assign hsync = result_stream[`hs];
    assign vsync = result_stream[`vs];

    always @(*) begin
        rgb = def_bg; // default background color
        if ( ab & valid )
          rgb = o_font0_data ? fg : bg;
        // // Debug Draw a border
        // else if (px_y3 <= 0+7 || px_y3 >= 479-7 || px_x3 <= 0+7 || px_x3 >= 639-7 )
        //   rgb = `GREEN;
        else
          rgb = def_bg; // default background color
    end

    wire endframe = ( px_x3 == 639 ) && ( px_y3 == 479 );

    // Register test.
    reg [7:0] framecounter = 8'h 00;  // Frame counter
    reg [7:0] counter = 8'h 00;   // Counter to show.

    // Register temporal test.
    always @(posedge endframe)
    begin
        framecounter <= framecounter + 1;
    end


    `ifndef SYNTHESIS // SIMULATION
      localparam ratio=0;
    `else // SYNTHESIS
      localparam ratio=4;
    `endif

    always @(posedge framecounter[ratio])
    begin
        counter <= counter + 1;
    end

    assign leds = counter;

    // ---------------------------------------- //
    // Power-Up Reset
    // reset_n low for (2^reset_counter_size) first clocks
    wire reset_n;

    localparam reset_counter_size = 2;
    reg [(reset_counter_size-1):0] reset_reg = 0;

    always @(posedge clk)
        reset_reg <= reset_reg + { {(reset_counter_size-1) {1'b0}} , !reset_n};

    assign reset_n = &reset_reg;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // UART-RX
    //
    // input ports
    wire       rx_i_uart_rx;
    // output ports
    wire       rx_o_wr;
    wire [7:0] rx_o_data;
    rxuartlite #(.CLOCKS_PER_BAUD(baudsDivider)) rx (
        .i_clk(clk),
        .i_uart_rx(rx_i_uart_rx),
        .o_wr(rx_o_wr),
        .o_data(rx_o_data)
    );
    // Connect inputs
    assign rx_i_uart_rx = RX;
    // ---------------------------------------- //


    // ---------------------------------------- //
    // INBOX (FIFO)
    //
    wire              INBOX_i_wr;
    wire signed [7:0] INBOX_i_data;
    wire              INBOX_i_rd;
    wire signed [7:0] INBOX_o_data;
    wire              INBOX_empty_n;
    wire              INBOX_full;
    wire              INBOX_i_rst;
    // dump ports
    wire              INBOX_i_dmp_clk;
    wire        [4:0] INBOX_i_dmp_pos;
    wire        [7:0] INBOX_o_dmp_data;
    wire              INBOX_o_dmp_valid;

    /* verilator lint_off PINMISSING */
    ufifo #(.LGFLEN(4'd5)) INBOX (
        // write port (push)
        .i_wr(INBOX_i_wr),
        .i_data(INBOX_i_data),
        // read port (pop)
        .i_rd(INBOX_i_rd),
        .o_data(INBOX_o_data),
        // flags
        .o_empty_n( INBOX_empty_n ), // not empty
        .o_full( INBOX_full ),
        // .o_status(),
        // dump ports
        .i_dmp_clk(INBOX_i_dmp_clk),     // dump position in queue
        .i_dmp_pos(INBOX_i_dmp_pos),     // dump position in queue
        .o_dmp_data(INBOX_o_dmp_data),   // value at dump position
        .o_dmp_valid(INBOX_o_dmp_valid), // i_dmp_pos is valid
        // clk, rst
        .i_rst(INBOX_i_rst),
        .i_clk(clk)
    );
    /* verilator lint_on PINMISSING */
    defparam INBOX.RXFIFO=1'b1;
    // Connect inputs
    assign INBOX_i_data = rx_o_data;
    assign INBOX_i_wr = rx_o_wr;
    assign INBOX_i_rd = sw1_d;
    assign INBOX_i_rst = 0;
    assign INBOX_i_dmp_clk = px_clk;
    assign INBOX_i_dmp_pos = o_vgaLabel3_out[`addr_s +: 4'd5];
    // ---------------------------------------- //

    assign TX=RX; // UART Loopback

endmodule

