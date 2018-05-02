`default_nettype none

module image (
    // Read ports:
    input clk,
    input wire [6:0] row,
    input wire [6:0] col,
    output reg data,
    // Write ports
    input wire [6:0] rowW,  // line number we write
    input wire [79:0] dataW // full 80 bits of the line
  );

  // 60 rows of 80 bits
  reg [79:0] rom [0:59];

  // parameter ROMFILE = "image.rom";

  // initial begin
  //   $readmemb(ROMFILE, rom);
  // end

  // Read Rom Logic
  always @(negedge clk) begin
    data <= rom[row][col];
  end

  reg [6:0] counter = 0;

  // Write logic
  always @(posedge clk) begin
    if (rowW != row) begin // don't write rowW if we are reading the same row.
      rom [rowW] <= dataW;
    end
  end

endmodule
