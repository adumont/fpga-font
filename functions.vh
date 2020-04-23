`ifndef __FUNCTIONS_VH__
`define __FUNCTIONS_VH__

`include "const.vh"

// Zoom - xc

function automatic [`xc_w-1:0] get_xc;
  input [`stream] in;

  begin
    get_xc = in[ `xc_s +: `xc_w ];
  end
endfunction

// Zoom - yc

function automatic [`yc_w-1:0] get_yc;
  input [`stream] in;

  begin
    get_yc = in[ `yc_s +: `yc_w ];
  end
endfunction

// Zoom - zm

function automatic [`zm_w-1:0] get_zm;
  input [`stream] in;

  begin
    get_zm = in[ `zm_s +: `zm_w ];
  end
endfunction

function automatic [`stream] set_zm;
  input [`stream] in;
  input [`zm_w-1:0] zm;

  begin
    set_zm = { 
      in[ (`zm_s + `zm_w) +: (`stream_w - `zm_w - `zm_s ) ],
      ( in[ `zm_s +: `zm_w ] | zm ) ,
      in[ 0 +: `zm_s ]
    };
  end
endfunction

// Foreground color - fg

function automatic [`fg_w-1:0] get_fg;
  input [`stream] in;

  begin
    get_fg = in[ `fg_s +: `fg_w ];
  end
endfunction

function automatic [`stream] set_fg;
  input [`stream] in;
  input [`fg_w-1:0] fg;

  begin
    set_fg = { 
      in[ (`fg_s + `fg_w) +: (`stream_w - `fg_w - `fg_s ) ],
      ( in[ `fg_s +: `fg_w ] | fg ) ,
      in[ 0 +: `fg_s ]
    };
  end
endfunction

// Background color - bg

function automatic [`bg_w-1:0] get_bg;
  input [`stream] in;

  begin
    get_bg = in[ `bg_s +: `bg_w ];
  end
endfunction

function automatic [`stream] set_bg;
  input [`stream] in;
  input [`bg_w-1:0] bg;

  begin
    set_bg = { 
      in[ (`bg_s + `bg_w) +: (`stream_w - `bg_w - `bg_s ) ],
      ( in[ `bg_s +: `bg_w ] | bg ) ,
      in[ 0 +: `bg_s ]
    };
  end
endfunction

// Background color - ha

function automatic [`ha_w-1:0] get_ha;
  input [`stream] in;

  begin
    get_ha = in[ `ha_s +: `ha_w ];
  end
endfunction

function automatic [`stream] set_ha;
  input [`stream] in;
  input [`ha_w-1:0] ha;

  begin
    set_ha = { 
      in[ (`ha_s + `ha_w) +: (`stream_w - `ha_w - `ha_s ) ],
      ( in[ `ha_s +: `ha_w ] | ha ) ,
      in[ 0 +: `ha_s ]
    };
  end
endfunction

// Address for RAM/ROM lookup - addr

function automatic [`addr_w-1:0] get_addr;
  input [`stream] in;

  begin
    get_addr = in[ `addr_s +: `addr_w ];
  end
endfunction

function automatic [`stream] set_addr;
  input [`stream] in;
  input [`addr_w-1:0] addr;

  begin
    set_addr = { 
      //in[ (`addr_s + `addr_w) +: (`stream_w - `addr_w - `addr_s ) ],
      ( in[ `addr_s +: `addr_w ] | addr ) ,
      in[ 0 +: `addr_s ]
    };
  end
endfunction


`endif // __FUNCTIONS_VH__