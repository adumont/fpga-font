`default_nettype none

module font (
        input wire        px_clk,      // Pixel clock.
        input wire [9:0]  pos_x,       // X screen position.
        input wire [9:0]  pos_y,       // Y screen position.
        input wire [7:0]  character,   // Character to stream.
        output reg data
    );

    parameter FILE_FONT = "font.list";

    // Width and height image of font.
    // 16x16 characters, 8x8 bit each
    localparam w = 128;  // Font rom width
    localparam h = 128;  // Font rom height

    initial
    begin
        $readmemb(FILE_FONT, rom);
    end

    wire [6:0] row;
    wire [6:0] bit;

    assign row =  { character[7:4] , pos_y[2:0] }; // which row in the FONT rom?
    assign bit = ~{ character[3:0] , pos_x[2:0] }; // which column in the row? (we reverse with ~ because of how the rom FONT is loaded )

    // Read Rom Logic
    reg [w-1:0] rom [0:h-1];

    always @(posedge px_clk) begin
        data <= rom[row][bit];
    end
    // End Read Rom Logic

endmodule
