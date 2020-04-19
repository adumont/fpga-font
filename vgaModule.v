`default_nettype none
`include "const.vh"

module vgaModule #(
    parameter   line =  10'd 0,  // position of the component on screen (vertical)
    parameter   col  =  10'd 0,  // position of the component on screen (horizontal)
    parameter   pzoom =  0,
    parameter   pcolor = `WHITE,
    parameter   width  = 1,
    parameter   height = 1,
    parameter   offset = 8'h 00
  ) (
    // input
    input wire         px_clk,
    input wire  [9:0]  x,  // X screen position.
    input wire  [9:0]  y,  // Y screen position.
    input wire         en, // enabled
    // interface with memory: addr to fetch / data retrieved
    output reg  [7:0]  addr,   // addr of the char to retrieve
    input wire  [7:0]  din,   // addr of the char to retrieve
    // output: data to show
    output reg  [7:0]  dout,  // data to render
    output reg  [2:0]  color,
    output reg  [1:0]  zoom,
    output reg         h2a    // requieres translation of Hex Nibble to Digit
  );

  // this component needs tranlation, 0 or 1.
  localparam ch2a = 1'b 0;

  /* verilator lint_off UNSIGNED */
  wire active0 = en
      && ( (x >> (3+pzoom)) >= ( col           ) )
      && ( (x >> (3+pzoom))  < ( col  + width  ) )
      && ( (y >> (3+pzoom)) >= ( line          ) )
      && ( (y >> (3+pzoom))  < (line + height  ) );
  /* verilator lint_on UNSIGNED */

  wire [9:0] rel_x, rel_y;

  assign rel_x = ( x >> (3+pzoom) ) - col ;  // relative position in the...
  assign rel_y = ( y >> (3+pzoom) ) - line ; // ..."component's area"

  always @(*)
  begin
    addr  = 8'h 00;
    dout  = 8'h 00;
    h2a   = 1'b  0;
    color = `BLACK;
    zoom  = 0;
    if( active0 ) begin
      addr = rel_x[7:0] + offset;
    end
    if( active1 ) begin
      dout  = din;
      h2a   = ch2a;
      color = pcolor;
      zoom  = pzoom;
    end
  end

  reg  active1 = 1'b  0;

  always @(posedge px_clk)
  begin
    active1 <= active0;
  end

endmodule