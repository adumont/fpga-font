`default_nettype none

module ram #(parameter Zoom = 0) (din, write_en, waddr, wclk, raddr, rclk, dout);
    parameter addr_width = 7; // Value: 0..80  < 128=2^7
    parameter data_width = 8; // Value: 0..255
    input rclk;
    input [addr_width-1:0] raddr;
    output reg [data_width-1:0] dout;
    input wclk;
    input write_en;
    input [addr_width-1:0] waddr;
    input [data_width-1:0] din;

    reg [data_width-1:0] mem [(1<<addr_width)-1:0];

    parameter ROMFILE = "ram.list";
    initial begin
        $readmemh(ROMFILE, mem);
    end

    always @(posedge rclk) // Read memory.
    begin
        dout <= mem[raddr]; // Using read address bus.
    end

    always @(posedge wclk) // Write memory.
    begin
        if (write_en) mem[waddr] <= din; // Using write address bus.
    end

endmodule