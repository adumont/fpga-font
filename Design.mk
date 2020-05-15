TOP:=top

MODULE?=$(TOP)

AUXFILES_font:=\
    font_rom.hex

AUXFILES_TOP:= \
    $(AUXFILES_font) \
    Labels.lst

MUSTACHE_GENERATED:=Labels.lst vgaModulesPipe.v vgaLabels.v

ifeq ($(MODULE), $(TOP))

  AUXFILES:=$(AUXFILES_TOP)

else ifeq ($(MODULE), tilemem)

  AUXFILES:=$(AUXFILES_tilemem)

else ifeq ($(MODULE), font)

  AUXFILES:=$(AUXFILES_font)

endif

YOSYSOPT:=-abc9
#YOSYSOPT:=-retime -abc2

ifndef MEMORY
	MEMORY="1k"
endif

