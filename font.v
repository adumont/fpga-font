`default_nettype none

module font (
        input wire        px_clk,      // Pixel clock.
        input wire [9:0]  pos_x,       // X screen position.
        input wire [9:0]  pos_y,       // Y screen position.
        input wire [`FONT_WIDTH-1:0]  character,   // Character to stream.
        output reg data
    );

    parameter FILE_FONT = "BRAM_8.list";

    // Width and height image of font.
    // 16x16 characters, 8x8 col each
    localparam w = 8;  // Font rom width = 8
    localparam h = (2**`FONT_WIDTH)*8;  // Font rom height = 8

    reg [w-1:0] rom [0:h-1];
    
    initial begin
        $readmemb(FILE_FONT, rom);
    end

    wire [(`FONT_WIDTH-1)+3:0] row;
    wire [2:0] col;

    assign row =  { character, pos_y[2:0] }; // which row in the FONT rom?
    assign col =  ~ pos_x[2:0];

    // Read Rom Logic
    always @(posedge px_clk) begin
        data <= rom[row][col];
    end
    // End Read Rom Logic
    
endmodule
