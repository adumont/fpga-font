`default_nettype none
`include "const.vh"

module vgaRegister #(
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
  localparam ch2a = 1'b 1;

  /* verilator lint_off UNSIGNED */
  wire active0 = 
         ( (x >> (3+pzoom)) >= ( col           ) )
      && ( (x >> (3+pzoom))  < ( col  + width  ) )
      && ( (y >> (3+pzoom)) >= ( line          ) )
      && ( (y >> (3+pzoom))  <  (line + height ) );
  /* verilator lint_on UNSIGNED */

  wire [9:0] rel_x, rel_y;

  assign rel_x = ( x >> (3+pzoom) ) - col ;  // relative position in the...
  assign rel_y = ( y >> (3+pzoom) ) - line ; // ..."component's area"

  reg nibble0, nibble1; // 0: [7:4], 1: [3:0]

  always @(*)
  begin
    addr  = 8'h 00;
    dout  = 8'h 00;
    h2a   = active1;
    color = `BLACK;
    zoom  = 0;
    nibble0 = rel_x[0:0];

    if( active1 ) begin
      if(nibble1) 
        dout  = { 4'h x, din[3:0] };
      else
        dout  = { 4'h x, din[7:4] };

      color = pcolor;
      zoom  = pzoom;
    end
  end

  reg  active1 = 1'b  0;

  always @(posedge px_clk)
  begin
    active1 <= active0;
    nibble1 <= nibble0;
  end

  // always @(*)
  // begin
  // end

endmodule