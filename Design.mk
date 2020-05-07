TOP:=top

MODULE?=$(TOP)

DEPS_font:=\
    ram.v

AUXFILES_font:=\
    font_rom.hex

DEPS_tilemem:=\
    ram.v

AUXFILES_tilemem:=\
    ram.list\
    ram65.list\
  	const.vh

DEPS_TOP:= \
    font.v $(DEPS_font) \
    hex2asc.v \
    register.v \
    ram.v \
    vgaModule.v \
    vgaWord.v \
    ufifo.v \
    rxuartlite.v \
    debouncer.v \
    vgaModulesPipe.v \
    vga_sync.v

AUXFILES_TOP:= \
    $(AUXFILES_font) \
    $(AUXFILES_tilemem) \
    Labels.lst \
    vgaModuleDebug.vh \
  	const.vh

ifeq ($(MODULE), $(TOP))

  DEPS:=$(DEPS_TOP)
  AUXFILES:=$(AUXFILES_TOP)

else ifeq ($(MODULE), tilemem)

  DEPS:=$(DEPS_tilemem)
  AUXFILES:=$(AUXFILES_tilemem)

else ifeq ($(MODULE), font)

  DEPS:=$(DEPS_font)
  AUXFILES:=$(AUXFILES_font)

endif

YOSYSOPT:=-retime -abc2

ifndef MEMORY
	MEMORY="1k"
endif
