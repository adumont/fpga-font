`default_nettype none
`include "const.vh"

module vgaModule #(
    parameter   line =  10'd 0,  // position of the component on screen (vertical)
    parameter   col  =  10'd 0,  // position of the component on screen (horizontal)
    parameter   zoom =  0,
    parameter   ccolor = `WHITE,
    parameter   width  = 1,
    parameter   height = 1,
    parameter   offset = 8'h 00,
    parameter   cid  =  0   // can never be 0
  ) (
    // input
    input wire         px_clk,
    input wire  [9:0]  x,  // X screen position.
    input wire  [9:0]  y,  // Y screen position.
    // interface with memory: addr to fetch / data retrieved
    output reg  [7:0]  id,     // component ID
    output reg  [7:0]  addr,   // addr of the char to retrieve
    input wire  [7:0]  din,   // addr of the char to retrieve
    // output: data to show
    output reg  [7:0]  dout,  // data to render
    output reg  [2:0]  color,
    output reg         n2d    // requieres translation Hex Nibble 2 Digit
  );

  // this component needs tranlation, 0 or 1.
  localparam cn2d = 1'b 0;

  wire active0 = 
         ( (x >> (3+zoom)) >= ( col           ) )
      && ( (x >> (3+zoom))  < ( col  + width  ) )
      && ( (y >> (3+zoom)) >= ( line          ) )
      && ( (y >> (3+zoom))  <  (line + height ) );

  wire [9:0] rel_x, rel_y;

  assign rel_x = ( x >> (3+zoom) ) - col ;  // relative position in the...
  assign rel_y = ( y >> (3+zoom) ) - line ; // ..."component's area"

  always @(*)
  begin
    id    = 8'h 00;
    addr  = 8'h 00;
    dout  = 8'h 00;
    n2d   = 1'b  0;
    color = `BLACK;
    if( active0 ) begin
      id   = cid;
      addr = rel_x[7:0] + offset;
    end
    if( active1 ) begin
      dout  = din;
      n2d   = cn2d;
      color = ccolor;
    end
  end

  reg  active1 = 1'b  0;

  always @(posedge px_clk)
  begin
    active1 <= active0;
  end

  // always @(*)
  // begin
  // end

endmodule