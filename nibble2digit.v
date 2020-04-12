`default_nettype none
`include "const.vh"

module nibble2digit(hex_digit, ascii_code);
    input [3:0] hex_digit;
    output reg [7:0] ascii_code;

    always @(*)
    begin
        ascii_code = 8'h00;
        case (hex_digit)
            4'h0: ascii_code = 8'h30;
            4'h1: ascii_code = 8'h31;
            4'h2: ascii_code = 8'h32;
            4'h3: ascii_code = 8'h33;
            4'h4: ascii_code = 8'h34;
            4'h5: ascii_code = 8'h35;
            4'h6: ascii_code = 8'h36;
            4'h7: ascii_code = 8'h37;
            4'h8: ascii_code = 8'h38;
            4'h9: ascii_code = 8'h39;
            4'hA: ascii_code = 8'h41;
            4'hB: ascii_code = 8'h42;
            4'hC: ascii_code = 8'h43;
            4'hD: ascii_code = 8'h44;
            4'hE: ascii_code = 8'h45;
            4'hF: ascii_code = 8'h46;
            default: ascii_code = 8'h00;
        endcase
    end
endmodule
