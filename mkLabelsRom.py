#!/usr/bin/env python3

labels = [
  "HRM",
  "CPU",
  "By @adumont",
  "IN:",
  "OUT:",
]

addr = 0

for label in labels:
  s = len(label)
  print("// Addr: %d Len: %d" % (addr, s))
  print("// \"%s\"" % label)
  addr = addr + s
  print(''.join('%02x ' % ord(a) for a in label ))
  print()
