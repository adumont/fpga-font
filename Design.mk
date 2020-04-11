TOP:=top

MODULE?=$(TOP)

DEPS_font:=

AUXFILES_font:=\
    BRAM_8.list

DEPS_tilemem:=\
    ram.v

AUXFILES_tilemem:=\
    ram.list\
    ram65.list\
  	const.vh

DEPS_TOP:= \
    font.v $(DEPS_font) \
    texto.v \
    vga_sync.v

AUXFILES_TOP:= \
    $(AUXFILES_font) \
    $(AUXFILES_tilemem) \
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
