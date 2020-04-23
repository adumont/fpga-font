`ifndef __CONST_VH__
`define __CONST_VH__

// Font addr width: ascii 7 bit
`define FONT_WIDTH 8

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
`define fg 24:22 // Foreground color (3 bits)
`define bg 27:25 // Background color (3 bits)
`define zm 29:28 // Zoom (2 bits)
`define ha 30:30 // Hex to Ascii (1 bit)
`define addr 41:31 // Address for RAM/ROM lookup (11 bits)

`define stream 41:0 // whole vector
`define vpart1 21:0 // LSB part of the vector
`define vpart2 41:22 // MSB part of the vector

// start bits
`define hs_s 0 // Horizontal sync, start bit
`define vs_s 1 // Vertical Sync, start bit
`define xc_s 2 // pixel X coordinate, start bit
`define yc_s 12 // pixel Y coordinate, start bit
`define fg_s 22 // Foreground color, start bit
`define bg_s 25 // Background color, start bit
`define zm_s 28 // Zoom, start bit
`define ha_s 30 // Hex to Ascii, start bit
`define addr_s 31 // Address for RAM/ROM lookup, start bit

`define stream_s 0 // whole vector, start bit
`define vpart1_s 0 // LSB part of the vector, start bit
`define vpart2_s 22 // MSB part of the vector, start bit

// widths
`define hs_w 1 // Horizontal sync, width
`define vs_w 1 // Vertical Sync, width
`define xc_w 10 // pixel X coordinate, width
`define yc_w 10 // pixel Y coordinate, width
`define fg_w 3 // Foreground color, width
`define bg_w 3 // Background color, width
`define zm_w 2 // Zoom, width
`define ha_w 1 // Hex to Ascii, width
`define addr_w 11 // Address for RAM/ROM lookup, width

`define stream_w 42 // whole vector, width
`define vpart1_w 22 // LSB part of the vector, width
`define vpart2_w 20 // MSB part of the vector, width

`endif // __CONST_VH__