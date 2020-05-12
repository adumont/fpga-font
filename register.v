`ifndef __REGISTER_V__
`define __REGISTER_V__

`default_nettype none

module register #( parameter w=1 ) (
    input wire  clk, 
    input wire  [w-1:0] in,
    output reg  [w-1:0] out
  );

  always @( posedge clk )
    out <= in;
endmodule
`endif // __REGISTER_V__