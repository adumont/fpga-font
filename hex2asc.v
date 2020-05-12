`ifndef __HEX2ASC_V__
`define __HEX2ASC_V__

`default_nettype none
`include "const.vh"

module hex2asc(
    // input
    input wire [7:0] din,
    input wire       h2a, // hexadecimal to ascii?
    input wire       nb,  // nibble [0|1]
    // output
    output reg [7:0] dout
  );

  always @(*)
  begin
    dout = din;
    if (h2a) begin
      case ( nb ? din[3:0] : din[7:4]) // hexadecimal to ascii
          4'h0: dout = 8'h30;
          4'h1: dout = 8'h31;
          4'h2: dout = 8'h32;
          4'h3: dout = 8'h33;
          4'h4: dout = 8'h34;
          4'h5: dout = 8'h35;
          4'h6: dout = 8'h36;
          4'h7: dout = 8'h37;
          4'h8: dout = 8'h38;
          4'h9: dout = 8'h39;
          4'hA: dout = 8'h41;
          4'hB: dout = 8'h42;
          4'hC: dout = 8'h43;
          4'hD: dout = 8'h44;
          4'hE: dout = 8'h45;
          4'hF: dout = 8'h46;
          default: dout = 8'h00;
      endcase
    end
  end
endmodule
`endif // __HEX2ASC_V__
