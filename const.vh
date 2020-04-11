`ifndef __CONST_VH__
`define __CONST_VH__

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

`endif // __CONST_VH__
