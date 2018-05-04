`default_nettype none

// check connections to VGA adapter on https://github.com/Obijuan/MonsterLED/wiki

module top (
        input  wire       clk,       // System clock.

        output wire       hsync,     // Horizontal sync out signal
        output wire       vsync,     // Vertical sync out signal
        output wire [2:0] rgb,       // Red/Green/Blue VGA signal

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

    // STAGE 1

    // buffer vga signals for 1 clock cycle 
    wire [9:0] px_x1, px_y1;
    wire [9:0] px_x2, px_y2;

    always @( posedge px_clk) begin
      { px_x1, px_y1 } <= { px_x0, px_y0 };
      { px_x2, px_y2 } <= { px_x1, px_y1 };
    end

    wire [7:0] char_code;
    wire [6:0] raddr;
    wire [7:0] rdata;

    assign raddr = px_x0[9:(3+`Zoom)]; // for now, we address only 1 line

    ram #( .Zoom(`Zoom) ) ram0 (
        .rclk( px_clk ),
        .raddr( raddr ),
        .dout( rdata ),
        .wclk( px_clk ),
        .write_en( 1'b0 ) // disable write port for now
    );

    assign char_code = rdata;

    // STAGE 2
    wire font_bit;

    font font0 (
        .px_clk(px_clk),      // Pixel clock.
        .pos_x(px_x1 >> `Zoom),       // X screen position.
        .pos_y(px_y1 >> `Zoom),       // Y screen position.
        .character( char_code ),   // Character to stream.
        .data( font_bit )     // Output RGB stream.
    );

    always @(*) begin
        rgb <= 3'b000;
        if (activevideo0) begin
            if( px_y2[9:3] >> `Zoom == 7'd 10
                //&& px_x2[9:3] >> `Zoom == 7'd 0 
                )
                rgb <= font_bit ? 3'b010 : 3'b000;
            // else if (px_y1 == 0 || px_y1 == 479 || px_x1 == 0 || px_x1 == 639 ) 
            //     rgb <= 3'b001;
            else
                rgb <= 3'b000;
        end
        else
            rgb <= 3'b000;
    end

    assign hsync = hsync0;
    assign vsync = vsync0;
endmodule
