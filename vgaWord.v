`ifndef __VGAWORD_V__
`define __VGAWORD_V__

`default_nettype none
`include "const.vh"

module vgaWord #(
    // "derives" vgaModule
    parameter   line =  6'd 0,  // position of the component on screen (vertical)
    parameter   col  =  7'd 0,  // position of the component on screen (horizontal)
    parameter   pzoom =  `zm_w'b 0,
    parameter   pcolor = `WHITE,
    parameter   width  = 1,
    parameter   cs  = `cs_w'd 1,
    parameter   offset = 5'd 0
  ) (
    // input
    input wire            px_clk,
    input wire  [`stream] in, // input stream
    input wire            en, // enabled
    // output
    output reg  [`stream] out // output stream
  );
  
  // this component needs tranlation, 0 or 1.
  localparam ch2a = 1'b 1;

// DEBUG
// `include "vgaModuleDebug.vh"
// end DEBUG

  wire [`xc_w-1:0] x = in[ `xc_s +: `xc_w ];
  wire [`yc_w-1:0] y = in[ `yc_s +: `yc_w ];

  wire [`xc_w-4:0] char_x = x[3 +: `xc_w-3] >> pzoom;
  wire [`yc_w-5:0] char_y = y[4 +: `yc_w-4] >> pzoom;

  // Active means Enabled and x,y is in the 
  /* verilator lint_off UNSIGNED */
  wire active = en && rel_x[1] && ( position != {5{1'b1}})
      && ( char_x >= ( col          ) )
      && ( char_x  < ( col  + width ) )
      && ( char_y >= ( line         ) )
      && ( char_y  < ( line + 4     ) );
  /* verilator lint_on UNSIGNED */

  wire [`xc_w-3-1:0] rel_x = char_x - col ;  // relative position in the block
  wire [`xc_w-4-1:0] rel_y = char_y - line ;  // relative position in the block
  wire [`vpart2_w-1:0] tmp;

  wire [4:0] t_offset = (rel_y[1] == 0) ? offset : (offset+5'd 16);
  wire [4:0] position = rel_x[2 +:5] + t_offset;

  assign tmp = {
      {3'b0, position }, // addr
      rel_y[0] ? cs : `cs_w'd 3, // chip select
      ch2a,
      rel_x[0], // nibble
      pzoom,
      `BLACK, // bg color // TODO implement parameter
      rel_y[0] ? pcolor : `YELLOW,
      active
     };

  always @(posedge px_clk)
  begin
    out[`vpart1] <= in[`vpart1];
    if(active)
      out[`vpart2] <= in[`vpart2] | tmp ;
    else
      out[`vpart2] <= in[`vpart2];
  end

endmodule
`endif // __VGAWORD_V__