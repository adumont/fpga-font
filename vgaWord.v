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
`include "vgaModuleDebug.vh"
// end DEBUG

  wire [`xc_w-1:0] x = in[ `xc_s +: `xc_w ];
  wire [`yc_w-1:0] y = in[ `yc_s +: `yc_w ];

  // Active means Enabled and x,y is in the 
  /* verilator lint_off UNSIGNED */
  wire active = en && rel_x[1] 
      && ( (x[3 +: `xc_w-3] >> pzoom ) >= ( col          ) )
      && ( (x[3 +: `xc_w-3] >> pzoom )  < ( col  + width ) )
      && ( (y[4 +: `yc_w-4] >> pzoom ) == ( line         ) );
  /* verilator lint_on UNSIGNED */

  wire [`xc_w-3-1:0] rel_x = ( x[3 +: `xc_w-3] >> pzoom ) - col ;  // relative position in the block

  wire [`vpart2_w-1:0] tmp;

  assign tmp = {
      {3'b0, rel_x[2 +:5] + offset }, // addr
      cs, // chip select
      ch2a,
      rel_x[0], // nibble
      pzoom,
      `BLACK, // bg color // TODO implement parameter
      pcolor,
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