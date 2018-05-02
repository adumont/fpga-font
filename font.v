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
    localparam w = 8;      // Font rom width
    localparam h = 128*8;  // Font rom height

    initial
    begin
        $readmemb(FILE_FONT, rom);
    end

    wire [10:0] row;
    wire [2:0] bit;

    assign row = { character , pos_y[2:0] };
    assign bit = pos_x[2:0];

    // Read Rom Logic
    reg [w-1:0] rom [0:h-1];

    always @(posedge px_clk) begin
        data <= rom[row][bit];
    end
    // End Read Rom Logic

endmodule
