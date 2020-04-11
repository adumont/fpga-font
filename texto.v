`default_nettype none
`include "const.vh"

module texto(index, ascii_code);
    input [3:0] index;
    output reg [7:0] ascii_code;

    always @(*)
    begin
        ascii_code = 8'h00;
        case (index)
            4'h0: ascii_code = 8'h41; // A
            4'h1: ascii_code = 8'h6c; // l
            4'h2: ascii_code = 8'h65; // e
            4'h3: ascii_code = 8'h78; // x
            4'h4: ascii_code = 8'h21; // !
            default: ascii_code = 8'h00;
        endcase
    end
endmodule
