`default_nettype none

module ram #(
        parameter Zoom = 0, 
        parameter addr_width =  7,
        parameter data_width =  8
    ) (
        // din, write_en, waddr, wclk, raddr, rclk, dout
        input rclk,
        input [addr_width-1:0] raddr,
        output reg [data_width-1:0] dout,
        input wclk,
        input write_en,
        input [addr_width-1:0] waddr,
        input [data_width-1:0] din
    );

    reg [data_width-1:0] mem [(1<<addr_width)-1:0];

    parameter ROMFILE = "ram.list";
    initial begin
        $readmemh(ROMFILE, mem);
        dout=0;
    end

    always @(posedge rclk) // Read memory.
    begin
        dout <= mem[raddr]; // no funciona!? (sintetizado)
        // dout <= raddr; // funciona!

        // case (raddr)
        //   7'h 00: dout <= 8'h 01;
        //   7'h 02: dout <= 8'h 32;
        //   7'h 04: dout <= 8'h 31;
        //   7'h 0A: dout <= 8'h 30;
        //   default: dout <= 8'h 00;
        // endcase
    end

    always @(posedge wclk) // Write memory.
    begin
        if (write_en) mem[waddr] <= din; // Using write address bus.
    end

endmodule