#!/usr/bin/env python3

labels = [
  "A label:",
  "Another Label:",
  "HrmCPU",
  "A CPU designed in Verilog",
  "Author:",
  "@adumont",
  "Frame:"
]

addr = 0

for label in labels:
  s = len(label)
  print("// Addr: %d Len: %d" % (addr, s))
  print("// \"%s\"" % label)
  addr = addr + s
  print(''.join('%02x ' % ord(a) for a in label ))
  print()
