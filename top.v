`default_nettype none

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

    `define Zoom 1

    // wire [`25:0] VGAstr0, VGAstr1;

    // STAGE 1

    // buffer vga signals for 1 clock cycle 
    reg [9:0] px_x1, px_y1;
    reg [9:0] px_x2, px_y2;
    reg [9:0] px_x3, px_y3;
    reg hsync1, vsync1, activevideo1;
    reg hsync2, vsync2, activevideo2;
    reg hsync3, vsync3, activevideo3;

    always @( posedge px_clk) begin
      { hsync1, vsync1, activevideo1, px_x1, px_y1 } <= { hsync0, vsync0, activevideo0, px_x0, px_y0 };
      { hsync2, vsync2, activevideo2, px_x2, px_y2 } <= { hsync1, vsync1, activevideo1, px_x1, px_y1 };
      { hsync3, vsync3, activevideo3, px_x3, px_y3 } <= { hsync2, vsync2, activevideo2, px_x2, px_y2 };
    end

    wire [12-2*`Zoom:0] raddr;
    wire [7:0] rdata;

    reg [7:0] char_code;
    
    assign raddr = px_y0[9:(3+`Zoom)]*(80/(2**`Zoom)) + px_x0[9:(3+`Zoom)];
    
    // Delayed one cycle of clock data from RAM.
    always @(posedge px_clk)
    begin
         char_code <= rdata;
    end

    ram #( .addr_width( 13-2*`Zoom ), .data_width( 8 ) ) ram0 (
        .rclk( px_clk ),
        .raddr( raddr ),
        .dout( rdata ),
        .wclk( px_clk ),
        .write_en( 1'b0 ) // disable write port for now
    );
    
    // STAGE 2
    wire font_bit;

    font font0 (
        .px_clk(px_clk),      // Pixel clock.
        .pos_x( px_x2 >> `Zoom ),       // X screen position.
        .pos_y( px_y2 >> `Zoom ),       // Y screen position.
        .character( char_code ),   // Character to stream.
        .data( font_bit )     // Output RGB stream.
    );

    // TODO: Embed in a combination block
    // takes input: stream 3
    // TODO: place register at the end to sinc... (stream4)

    always @(*) begin
        if (activevideo3)
        begin
            if ( font_bit &&
                 px_y3[9:3] >> `Zoom < 7'd 4 )
                rgb <= 3'b010;
            else if (px_y3 == 0 || px_y3 == 479 || px_x3 == 0 || px_x3 == 639 )
                rgb <= 3'b100;
            else
                rgb <= 3'b000;
        end
        else
            rgb <= 3'b000;
    end

    assign hsync = hsync3;
    assign vsync = vsync3;
endmodule
