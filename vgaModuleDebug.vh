`ifndef __VGAMODULEDEBUG_V__
`define __VGAMODULEDEBUG_V__

// Stream in

wire [`hs_w-1:0] in_hs = in[`hs];
wire [`vs_w-1:0] in_vs = in[`vs];
wire [`xc_w-1:0] in_xc = in[`xc];
wire [`yc_w-1:0] in_yc = in[`yc];
wire [`av_w-1:0] in_av = in[`av];
wire [`ab_w-1:0] in_ab = in[`ab];
wire [`fg_w-1:0] in_fg = in[`fg];
wire [`bg_w-1:0] in_bg = in[`bg];
wire [`zm_w-1:0] in_zm = in[`zm];
wire [`nb_w-1:0] in_nb = in[`nb];
wire [`ha_w-1:0] in_ha = in[`ha];
wire [`cs_w-1:0] in_cs = in[`cs];
wire [`addr_w-1:0] in_addr = in[`addr];

// Stream out

wire [`hs_w-1:0] out_hs = out[`hs];
wire [`vs_w-1:0] out_vs = out[`vs];
wire [`xc_w-1:0] out_xc = out[`xc];
wire [`yc_w-1:0] out_yc = out[`yc];
wire [`av_w-1:0] out_av = out[`av];
wire [`ab_w-1:0] out_ab = out[`ab];
wire [`fg_w-1:0] out_fg = out[`fg];
wire [`bg_w-1:0] out_bg = out[`bg];
wire [`zm_w-1:0] out_zm = out[`zm];
wire [`nb_w-1:0] out_nb = out[`nb];
wire [`ha_w-1:0] out_ha = out[`ha];
wire [`cs_w-1:0] out_cs = out[`cs];
wire [`addr_w-1:0] out_addr = out[`addr];
`endif // __VGAMODULEDEBUG_V__
