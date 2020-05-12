PROJECT:=vga_test

RTL_DIR:=..
RTL_TOP:=top
GUI_DIR:=.

include $(RTL_DIR)/Design.mk

RTL_DEPS := $(addprefix $(RTL_DIR)/, $(DEPS))

RTL_PIPE := $(addprefix $(RTL_DIR)/, $(MUSTACHE_GENERATED))

.DEFAULT_GOAL := $(PROJECT)

VLIBS := verilated.o verilated_save.o verilated_vcd_c.o
VOBJS := $(addprefix $(RTL_DIR)/obj_dir/, $(VLIBS) V$(RTL_TOP)__ALLcls.o V$(RTL_TOP)__ALLsup.o )

$(RTL_PIPE): $(wildcard $(RTL_DIR)/mustache/*.mustache)
	make -C .. Labels.lst vgaModulesPipe.v vgaLabels.v

verilator: $(VOBJS) $(RTL_DEPS)

$(PROJECT): $(PROJECT).mk $(VOBJS) .FORCE
	cd $(GUI_DIR) && make -f $(PROJECT).mk

$(VOBJS): $(RTL_DIR)/$(RTL_TOP).v $(RTL_DEPS)
	cd $(RTL_DIR) && verilator --savable --trace --trace-max-array 256 --public -cc $(RTL_TOP).v
	make -C $(RTL_DIR)/obj_dir/ -f V$(RTL_TOP).mk V$(RTL_TOP)__ALL.a $(VLIBS)

$(PROJECT).mk: $(PROJECT).pro
	cd $(GUI_DIR) && qmake $(PROJECT).pro -r -spec linux-g++-64 -o $(PROJECT).mk

vclean:
	cd $(RTL_DIR) && rm -rf obj_dir/

qtclean:
	cd $(GUI_DIR) && rm -f $(PROJECT).mk $(PROJECT) *.o moc_*.cpp moc_*.h qrc_*.cpp ui_*.h

clean: vclean qtclean

run: $(PROJECT)
	./$(PROJECT)

.PHONY: clean .FORCE qtclean vclean verilator
