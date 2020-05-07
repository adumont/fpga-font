`ifndef __CONST_VH__
`define __CONST_VH__

// Font addr width: ascii 7 bit
`define FONT_WIDTH 8

// COLORS
`define BLACK  3'b 000
`define BLUE   3'b 001
`define GREEN  3'b 010
`define TEAL   3'b 011
`define RED    3'b 100
`define PINK   3'b 101
`define YELLOW 3'b 110
`define WHITE  3'b 111


// Vector parts
`define hs 0:0 // Horizontal sync (1 bit)
`define vs 1:1 // Vertical Sync (1 bit)
`define xc 11:2 // pixel X coordinate (10 bits)
`define yc 21:12 // pixel Y coordinate (10 bits)
`define av 22:22 // active video (1 bit)
`define ab 23:23 // active block (1 bit)
`define fg 26:24 // Foreground color (3 bits)
`define bg 29:27 // Background color (3 bits)
`define zm 31:30 // Zoom (2 bits)
`define nb 32:32 // Nibble [1|0] (1 bit)
`define ha 33:33 // Hex to Ascii (1 bit)
`define cs 36:34 // ram chip select (3 bits)
`define addr 44:37 // Address for RAM/ROM lookup (8 bits)

`define stream 44:0 // whole vector
`define vpart1 22:0 // LSB part of the vector
`define vpart2 44:23 // MSB part of the vector

// start bits
`define hs_s 0 // Horizontal sync, start bit
`define vs_s 1 // Vertical Sync, start bit
`define xc_s 2 // pixel X coordinate, start bit
`define yc_s 12 // pixel Y coordinate, start bit
`define av_s 22 // active video, start bit
`define ab_s 23 // active block, start bit
`define fg_s 24 // Foreground color, start bit
`define bg_s 27 // Background color, start bit
`define zm_s 30 // Zoom, start bit
`define nb_s 32 // Nibble [1|0], start bit
`define ha_s 33 // Hex to Ascii, start bit
`define cs_s 34 // ram chip select, start bit
`define addr_s 37 // Address for RAM/ROM lookup, start bit

`define stream_s 0 // whole vector, start bit
`define vpart1_s 0 // LSB part of the vector, start bit
`define vpart2_s 23 // MSB part of the vector, start bit

// widths
`define hs_w 1 // Horizontal sync, width
`define vs_w 1 // Vertical Sync, width
`define xc_w 10 // pixel X coordinate, width
`define yc_w 10 // pixel Y coordinate, width
`define av_w 1 // active video, width
`define ab_w 1 // active block, width
`define fg_w 3 // Foreground color, width
`define bg_w 3 // Background color, width
`define zm_w 2 // Zoom, width
`define nb_w 1 // Nibble [1|0], width
`define ha_w 1 // Hex to Ascii, width
`define cs_w 3 // ram chip select, width
`define addr_w 8 // Address for RAM/ROM lookup, width

`define stream_w 45 // whole vector, width
`define vpart1_w 23 // LSB part of the vector, width
`define vpart2_w 22 // MSB part of the vector, width


// HACK... we'll use the in the stream (after reg1)
`define valid   `zm_s:`zm_s
`define valid_s `zm_s
`define valid_w 1

`endif // __CONST_VH__