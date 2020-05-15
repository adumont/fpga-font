#!/usr/bin/env python3

import pystache
import yaml
import contextlib
import argparse

@contextlib.contextmanager
def smart_open(filename=None, mode="w"):
  if filename and filename != '-':
    fh = open(filename, mode)
  else:
    if mode == "r":
      fh = os.fdopen(sys.stdin.fileno(), mode, closefd=False)
    else:
      fh = os.fdopen(sys.stdout.fileno(), mode, closefd=False)
  try:
    yield fh
  finally:
    if filename and filename != '-':
      fh.close()

render = pystache.Renderer(missing_tags="strict")

with open('modules.yaml') as f:
  data = yaml.load(f, Loader=yaml.FullLoader)
  # print(data["modules"])

indexByType = {}

wire = "in"
index = 0
modules_rendered=""

# Dict to map unique labels to addr
labels_addr = {}
addr = 0

# Generate Label Rom file with all labels
with smart_open("../Labels.lst", "w") as fh:
  for l in data["labels"]:
    s = l['label']
    w = len(s)

    l["width"] = w
    if 'cs'     not in l: l['cs'    ] = 0
    if 'zoom'   not in l: l['zoom'  ] = 0
    if 'fg'     not in l: l['fg'    ] = "`WHITE"
    if 'bg'     not in l: l['bg'    ] = "`BLACK"
    if 'col'    not in l: l['col'   ] = 0
    if 'line'   not in l: l['line'  ] = 0
    if 'offset' not in l: l['offset'] = 0
    if 'en'     not in l: l['en'    ] = "1'b1"

    if s in labels_addr:
      l["offset"] = labels_addr.get(s)
      continue # found, skip

    l["offset"] = addr

    print("// Addr: %d Width: %d" % (addr, w), file=fh)
    print("// \"%s\"" % s, file=fh)
    print(''.join('%02x ' % ord(a) for a in s ), file=fh)
    print("", file=fh)

    labels_addr[s]=addr
    addr = addr + w

with smart_open("../vgaLabels.v", "w") as fh:
  print(render.render_path( 'vgaLabels.mustache', data), file=fh )


# Generate vgaPipe with Modules instanciation
for m in data["modules"]:
  if 'name' not in m:
    if m['type'] not in indexByType:
      indexByType[m['type']]=0
    m['name']=m['type'] + str(indexByType[m['type']])
    indexByType[m['type']]=indexByType[m['type']]+1

  if m['type'] == "vgaLabels":
    m['extw' ] = data['extw']

  # Other default values if not provided
  if 'clk'  not in m: m['clk' ] = 'px_clk'
  if 'zoom' not in m: m['zoom'] = 0
  if 'fg'   not in m: m['fg'  ] = "`WHITE"
  if 'en'   not in m: m['en'  ] = "1'b1"
  if 'col'  not in m: m['col' ] = 0
  if 'line' not in m: m['line'] = 0
  if 'offset' not in m: m['offset'] = 0
  if 'cs' not in m: m['cs'] = 0
  
  m['in']  = wire

  this_module = render.render_path( m['type']+'_inst.mustache', m)

  modules_rendered = "%s\n%s" % (modules_rendered, this_module)

  wire="o_%s_out" % m['name']

with smart_open("../vgaModulesPipe.v", "w") as fh:
  print(render.render_path( 'vgaModulesPipe.mustache', {"modules_rendered":modules_rendered, "pipe_out":wire}, data), file=fh)