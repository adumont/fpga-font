`default_nettype none
`include "const.vh"

module font (
        input  wire       px_clk,      // Pixel clock.
        input  wire [9:0] pos_x,       // X screen position.
        input  wire [9:0] pos_y,       // Y screen position.
        input  wire [7:0] character,   // Character to stream.
        output wire       data
    );

    parameter FILE_FONT = "romfont.hex";

    wire [(`FONT_WIDTH-1)+3:0] row;
    wire [2:0] col;

    assign row =  { character, pos_y[2:0] }; // which row in the FONT rom?
    assign col =  ~ pos_x[2:0];

    reg [2:0] r_col;
    always @(posedge px_clk) begin
        r_col <= col;
    end
    // End Read Rom Logic

    // ---------------------------------------- //
    // fontRom (ram)
    //

    wire          i_fontRom_clk;
    wire [11-1:0] i_fontRom_addr;
    wire          i_fontRom_write_en;
    wire  [8-1:0] i_fontRom_din;
    wire  [8-1:0] o_fontRom_dout;

    ram fontRom (
    //---- input ports ----
    .clk     (i_fontRom_clk     ),
    .addr    (i_fontRom_addr    ),
    .write_en(i_fontRom_write_en),
    .din     (i_fontRom_din     ),
    //---- output ports ----
    .dout    (o_fontRom_dout    )
    );
    // Define Parameters:
    defparam fontRom.addr_width = 11; // 16*16*8 = 2^11
    defparam fontRom.data_width =  8; 
    defparam fontRom.ROMFILE = FILE_FONT;
    // Connect Inputs:
    assign i_fontRom_clk      = px_clk ;
    assign i_fontRom_addr     = row ;
    assign i_fontRom_write_en = 1'b 0 ;
    assign i_fontRom_din      = 8'b 0 ;
    // ---------------------------------------- //
    
    assign data = o_fontRom_dout[r_col];
    
endmodule
