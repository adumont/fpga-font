`include "const.vh"

module ztest();

  `include "functions.vh"

  reg [`stream] test_stream = {`stream_w {1'b 0} };

  initial
    begin


      $display("Hello World!");   // This will display a message


      // $display("%b", {`yc_s{1'b 0}} );
      // $display("%b", {`yc_w{1'b 1}} );

      // $display("%b", { (`stream_w - `yc_w - `yc_s ) {1'b 0} } );

      // $display("%b", 
      //   { { (`stream_w - `yc_w - `yc_s ) {1'b 0} },
      //     {`yc_w{1'b 1}},
      //     {`yc_s{1'b 0}}
      //   }
      // );

    // fg
    $display("fg");
    test_stream = {`stream_w {1'b 0} };

      $display("Stream In : %b", test_stream);

      test_stream = set_fg(test_stream, {`fg_w {1'b 1} });

      $display("Stream Out: %b", test_stream);

      $display("  fg : %b", get_fg(test_stream));

    // bg
    $display("bg");
    test_stream = {`stream_w {1'b 0} };

      $display("Stream In : %b", test_stream);

      test_stream = set_bg(test_stream, {`bg_w {1'b 1} });

      $display("Stream Out: %b", test_stream);

      $display("  bg : %b", get_bg(test_stream));

    // zm
    $display("zm");
    test_stream = {`stream_w {1'b 0} };

      $display("Stream In : %b", test_stream);

      test_stream = set_zm(test_stream, {`zm_w {1'b 1} });

      $display("Stream Out: %b", test_stream);

      $display("  zm : %b", get_zm(test_stream));

    // ha
    $display("ha");
    test_stream = {`stream_w {1'b 0} };

      $display("Stream In : %b", test_stream);

      test_stream = set_ha(test_stream, {`ha_w {1'b 1} });

      $display("Stream Out: %b", test_stream);

      $display("  ha : %b", get_ha(test_stream));

    // addr
    $display("addr");
    test_stream = {`stream_w {1'b 0} };

      $display("Stream In : %b", test_stream);

      test_stream = set_addr(test_stream, {`addr_w {1'b 1} });

      $display("Stream Out: %b", test_stream);

      $display("  addr : %b", get_addr(test_stream));


      $finish ; // This causes the simulation to end.  Without, it would go on..and on.
    end

endmodule