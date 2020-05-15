#!/usr/bin/env python3

import pystache
from os import walk

render = pystache.Renderer(missing_tags="strict")

assets_path="../assets/"
assets_files = []

for (dirpath, dirnames, filenames) in walk(assets_path):
    assets_files.extend(filenames)
    break

# Retrieve top dependencies (all modules.v files)
with open('../top.v.d') as f:
  deps = f.readline().strip().split()

modules=[]

for d in deps:
  if not d.endswith(".v"):
    # not a verilog module, skip
    continue
  modules.append({'name': d.replace('.v','')})

data={ 'modules': modules}

with open("../Diagrams.md", "w") as fh:
  print(render.render_path( 'Diagrams.mustache', data), file=fh )