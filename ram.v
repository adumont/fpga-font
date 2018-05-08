`default_nettype none

module ram #(
        parameter addr_width =  11,
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

    parameter ROMFILE = "";
    initial begin
        if(ROMFILE) $readmemh(ROMFILE, mem);
        dout=0;
        // $writememh("saved_ram.list",mem);
    end

    always @(posedge rclk) // Read memory
    begin
        dout <= mem[raddr];
    end

    always @(posedge wclk) // Write memory.
    begin
        if (write_en) mem[waddr] <= din; // Using write address bus.
    end

endmodule
