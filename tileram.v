`default_nettype none

module tileram  #(parameter ZOOM = 0)  (
    input Rclk,
    input wire [6:0] Raddr,
    output reg [7:0] Rdata,
    // Write Ports
    input clkW,
    input wire [6:0] Waddr,
    input wire [7:0] Wdata,
    input wire we
     );

  reg [7:0] ram [0:255];

  parameter ROMFILE = "tileram.list";

  initial begin
    $readmemh(ROMFILE, ram);
  end

  // Read logic
  always @(negedge Rclk) begin
      Rdata <= ram[Raddr];
  end

  // Write logic
  always @(posedge clkW) begin
      if( we ) ram[Waddr] <= Wdata;
  end

endmodule
