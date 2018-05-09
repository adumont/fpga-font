`default_nettype none

module register #( parameter W=1 ) (
    input wire  clk, 
    input wire  [W-1:0] in,
    output reg  [W-1:0] out
  );

  always @( posedge clk )
    out <= in;
endmodule