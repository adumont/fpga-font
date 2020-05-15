`ifndef __TOP_V__
`define __TOP_V__

`default_nettype none
`include "const.vh"
`include "vgaModulesPipe.v"
`include "debouncer.v"
`include "vga_sync.v"
`include "ram.v"
`include "register.v"
`include "hex2asc.v"
`include "rxuartlite.v"
`include "txuartlite.v"
`include "font.v"
`include "ufifo.v"
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

    wire sw2_d; // pulse when sw pressed
    wire sw2_u; // pulse when sw released
    wire sw2_s; // sw state
    debouncer db_sw2 (.clk(clk), .PB(sw2), .PB_down(sw2_d), .PB_up(sw2_u), .PB_state(sw2_s));
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

    // ---------------------------------------- //
    // vgaPipe (vgaModulesPipe)
    //

    wire           i_vgaPipe_px_clk;
    wire [`stream] i_vgaPipe_in;
    wire [`stream] o_vgaPipe_out;

    vgaModulesPipe vgaPipe (
      //---- input ports ----
      .px_clk(i_vgaPipe_px_clk),
      .in    (i_vgaPipe_in    ),
      //---- output ports ----
      .out   (o_vgaPipe_out   )
    );
    // Connect Inputs:
    assign i_vgaPipe_px_clk = px_clk ;
    assign i_vgaPipe_in     = vga_str0 ;
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
    assign i_labelsRam_addr     = o_vgaPipe_out[`addr]; // ADDR
    // we don't use write port here...
    assign i_labelsRam_write_en = 1'b 0 ;
    assign i_labelsRam_din      = 8'b 0 ;
    // ---------------------------------------- //

    // ---------------------------------------- //
    // passThrough (register)
    // Fake Ram (output address)

    wire         i_passThrough_clk;
    wire [`addr_w-1:0] i_passThrough_in;
    wire [`addr_w-1:0] o_passThrough_out;

    register passThrough (
      //---- input ports ----
      .clk(i_passThrough_clk),
      .in (i_passThrough_in ),
      //---- output ports ----
      .out(o_passThrough_out)
    );
    // Define Parameters:
    defparam passThrough.w = `addr_w;
    // Connect Inputs:
    assign i_passThrough_clk = px_clk ;
    assign i_passThrough_in  = o_vgaPipe_out[`addr]; // ADDR ;
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
    assign i_reg0_in  = o_vgaPipe_out[0 +: `addr_s]; // vga_str0[0 +: `addr_s];
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
        // `cs_w'd 2: { o_ramMux_valid, o_ramMux_dout } = { o_OUTBOX_o_dmp_valid, o_OUTBOX_o_dmp_data }; // OUTBOX, cs = 2
        `cs_w'd 3: { o_ramMux_valid, o_ramMux_dout } = { 1'b 1, o_passThrough_out } ; // Passthrough, cs = 3
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

    always @(*)
    begin
      rgb = `BLACK;
      if(activevideo3)
      begin
        if ( ab & valid )
          rgb = o_font0_data ? fg : bg;
        // // Debug Draw a border
        // else if (px_y3 <= 0+7 || px_y3 >= 479-7 || px_x3 <= 0+7 || px_x3 >= 639-7 )
        //   rgb = `GREEN;
        // else
        //   rgb = px_x3[5 +:3]; //def_bg; // px_x3[5 +:3]; // default background color
      end
      else
        // VGA spec, make sure rgb is BLACK (0) when screen not active!
        rgb = `BLACK;
      `ifndef SYNTHESIS // SIMULATION
        // Be sure VGA signal is black (0) when screen not active
        assert( activevideo3 | rgb == 3'b 000 );
      `endif
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

    // // ---------------------------------------- //
    // // Power-Up Reset
    // // reset_n low for (2^reset_counter_size) first clocks
    // wire reset_n;

    // localparam reset_counter_size = 2;
    // reg [(reset_counter_size-1):0] reset_reg = 0;

    // always @(posedge clk)
    //     reset_reg <= reset_reg + { {(reset_counter_size-1) {1'b0}} , !reset_n};

    // assign reset_n = &reset_reg;
    // // ---------------------------------------- //

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
    assign INBOX_i_rd = pop_inbox;
    assign INBOX_i_rst = 0;
    assign INBOX_i_dmp_clk = px_clk;
    assign INBOX_i_dmp_pos = o_vgaPipe_out[`addr_s +: 4'd5];
    // ---------------------------------------- //

    // wire pop_inbox = sw1_d;
    wire pop_inbox = ~o_tx_o_busy & sw1_d & INBOX_empty_n;

    // ---------------------------------------- //
    // tx (txuartlite)
    //

    wire       i_tx_i_clk;
    wire       i_tx_i_wr;
    wire [7:0] i_tx_i_data;
    wire       o_tx_o_uart_tx;
    wire       o_tx_o_busy;

    txuartlite tx (
      //---- input ports ----
      .i_clk    (i_tx_i_clk    ),
      .i_wr     (i_tx_i_wr     ),
      .i_data   (i_tx_i_data   ),
      //---- output ports ----
      .o_uart_tx(o_tx_o_uart_tx),
      .o_busy   (o_tx_o_busy   )
    );
    // Define Parameters:
    defparam tx.CLOCKS_PER_BAUD = baudsDivider;
    // Connect Inputs:
    assign i_tx_i_clk     = clk ;
    assign i_tx_i_wr      = pop_inbox ;
    assign i_tx_i_data    = INBOX_o_data ;
    // ---------------------------------------- //

    assign TX=o_tx_o_uart_tx; // UART Loopback

endmodule

`endif // __TOP_V__