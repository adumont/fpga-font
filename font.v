`default_nettype none

module font (
        input wire        px_clk,      // Pixel clock.
        input wire [9:0]  pos_x,       // X screen position.
        input wire [9:0]  pos_y,       // Y screen position.
        input wire [7:0]  character,   // Character to stream.
        output wire data
    );

    parameter FILE_FONT = "BRAM_8.list";

    // Width and height image of font.
    // 16x16 characters, 8x8 col each
    localparam w = 8;  // Font rom width
    localparam h = 16*16*8;  // Font rom height

    initial
    begin
        $readmemb(FILE_FONT, rom);
    end

    wire [10:0] row;
    wire [2:0] col;

    assign row =  { character, pos_y[2:0] }; // which row in the FONT rom?
    assign col =  ~ pos_x[2:0];

    // Read Rom Logic
    reg [w-1:0] rom [0:h-1];
    reg [7:0] dout;

    always @(posedge px_clk) begin
        dout <= rom[row];
    end
    // End Read Rom Logic
    
    assign data = dout[col];

endmodule
