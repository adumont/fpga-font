# call with make MODULE=moduleName sim|svg|upload

include Boards.mk
BOARD_BUILDDIR:=build/$(BOARD)
BUILDDIR:=$(BOARD_BUILDDIR)

include Design.mk

# load dependencies if exists
-include $(MODULE).v.d

%.v.d: %.v $(DEPS) $(MUSTACHE_GENERATED)
	@echo Generating dependencies file $@
	$(YOSYS) -q -E $@.tmp $<
	sed 's/:/DEPS:=/g' < $@.tmp > $@
	rm $@.tmp

.v.d:
	@true

FILTER_OUT = $(foreach v,$(2),$(if $(findstring $(1),$(v)),,$(v)))

# From dependencies, here we keep only .v files (excluding .vh)
SOURCES_V:=$(call FILTER_OUT,.vh, $(DEPS))

diagrams: $(addprefix assets/, $(SOURCES_V:.v=.svg)) top.v.d # $(addprefix assets/, $(SOURCES_V:.v=_dot.svg))
	cd mustache; ./mkDiagrams.py

assets/%.svg:
	make MODULE=$* svg

assets/%_dot.svg:
	make MODULE=$* dot

# Use Docker images
DOCKER=docker
#DOCKER=podman
#
PWD = $(shell pwd)
DOCKERARGS = run --rm -v $(PWD):/src -w /src
#
# DOCKER_YOSYS="adumont/yosys:master"
ifneq ($(DOCKER_YOSYS),)
YOSYS     = $(DOCKER) $(DOCKERARGS) $(DOCKER_YOSYS)
else
YOSYS=yosys
endif

NEXTPNR   = $(DOCKER) $(DOCKERARGS) ghdl/synth:nextpnr-ice40 nextpnr-ice40

BUILDDIR?=build/$(BOARD)
ARACHNE_SEED?=36747270

all: bin svg dot sim

bin: $(BUILDDIR)/$(MODULE).bin
vcd: $(MODULE)_tb.vcd
sim: vcd gtkwave
json: $(BUILDDIR)/$(MODULE)-netlist.json
svg: assets/$(MODULE).svg
dot: assets/$(MODULE)_dot.svg
lint: $(BOARD_BUILDDIR)/$(MODULE).lint
pipe: Labels.lst vgaModulesPipe.v
deps: $(MODULE).v.d
mustache: $(MUSTACHE_GENERATED)

# @echo '@: $@' # file name of the target
# @echo '%: $%' # name of the archive member

# @echo '<: $<' # name of the first prerequisite
# @echo '?: $?' # names of all prerequisites newer than the target
# @echo '^: $^' # names of all prerequisites
# @echo '|: $|' # names of all the order-only prerequisites
# @echo '*: $*' # stem with which an implicit rule matches
# @echo $(word 2, $?) 2nd word names of all prerequisites 

PCF:=$(MODULE)-$(BOARD).pcf

ifeq ($(PROGRAM),test/$(LEVEL)/program)
CLEAN_PROGRAM:=$(PROGRAM)

$(PROGRAM): test/$(LEVEL)/PROG
	make -C test/$(LEVEL) -f ../tester.mk program
endif

$(MODULE)_tb.vcd: $(MODULE).v $(DEPS) $(MODULE)_tb.v $(PROGRAM) $(ROMFILE)

	iverilog $(MODULE).v $(DEPS) $(MODULE)_tb.v $(IVERILOG_MACRO) -o $(MODULE)_tb.out
	./$(MODULE)_tb.out

$(BOARD_BUILDDIR)/$(MODULE).lint: $(MODULE).v $(DEPS) | $(BUILDDIR)

	verilator --lint-only $(MODULE).v && > $@ || ( rm -f $@; false )

gtkwave: $(MODULE).v $(DEPS) $(MODULE)_tb.v $(MODULE)_tb.vcd

	gtkwave $(MODULE)_tb.vcd $(MODULE)_tb.gtkw &

$(BOARD_BUILDDIR)/$(MODULE).json: $(MODULE).v $(DEPS) $(AUXFILES) $(BOARD_BUILDDIR)/build.config | $(BUILDDIR)
	
	$(YOSYS) -p "synth_ice40 -top $(MODULE) -json $(BOARD_BUILDDIR)/$(MODULE).json $(YOSYSOPT)" \
              -l $(BUILDDIR)/$(MODULE).log -q $(MODULE).v

$(BOARD_BUILDDIR)/$(MODULE).blif: $(MODULE).v $(DEPS) $(AUXFILES) $(BOARD_BUILDDIR)/build.config | $(BUILDDIR)
	
	$(YOSYS) -p "synth_ice40 -top $(MODULE) -blif $(BOARD_BUILDDIR)/$(MODULE).blif $(YOSYSOPT)" \
              -l $(BUILDDIR)/$(MODULE).log -q $(MODULE).v

# set ARACHNEPNR=1 to force arachne-pnr
ifneq ($(ARACHNEPNR),)
$(warning Building with arachne-pnr, because ARACHNEPNR=$(ARACHNEPNR))
$(BOARD_BUILDDIR)/$(MODULE).pnr: $(PCF) $(BOARD_BUILDDIR)/$(MODULE).blif

	arachne-pnr -s $(ARACHNE_SEED) -d $(PNRDEV) -p $(PCF) $(BOARD_BUILDDIR)/$(MODULE).blif -o $(BOARD_BUILDDIR)/$(MODULE).pnr

else
$(warning Building with nextpnr, because ARACHNEPNR=$(ARACHNEPNR))
$(BOARD_BUILDDIR)/$(MODULE).pnr: $(PCF) $(BOARD_BUILDDIR)/$(MODULE).json

	$(NEXTPNR) --hx$(PNRDEV) --package $(PNRPACK) --json $(BOARD_BUILDDIR)/$(MODULE).json --pcf $(PCF) --asc $@
endif

ifdef LEVEL
$( warning LEVEL=$(LEVEL))
$(BUILDDIR)/$(MODULE).pnr: $(BOARD_BUILDDIR)/$(MODULE).pnr $(PROGRAM) $(ROMFILE) | $(BUILDDIR)

	icebram dummy_prg.hex $(PROGRAM) < $(BOARD_BUILDDIR)/$(MODULE).pnr > $(BUILDDIR)/$(MODULE)-tmp.pnr && \
	icebram dummy_ram.hex $(ROMFILE) < $(BUILDDIR)/$(MODULE)-tmp.pnr > $(BUILDDIR)/$(MODULE).pnr && \
	rm $(BUILDDIR)/$(MODULE)-tmp.pnr
endif

$(BUILDDIR)/$(MODULE).bin: $(BOARD_BUILDDIR)/$(MODULE).lint $(BUILDDIR)/$(MODULE).pnr

	icepack $(BUILDDIR)/$(MODULE).pnr $(BUILDDIR)/$(MODULE).bin

upload: $(BUILDDIR)/$(MODULE).bin

	md5sum $(BUILDDIR)/$(MODULE).bin | cmp $(BOARD_BUILDDIR)/flashed.md5 && \
	( echo "INFO: FPGA $(BOARD) bitstream hasn't changed: Skipping programming and reseting board:" ; iceprog -t ) || \
	( iceprog $(BUILDDIR)/$(MODULE).bin && md5sum $(BUILDDIR)/$(MODULE).bin > $(BOARD_BUILDDIR)/flashed.md5 || rm $(BOARD_BUILDDIR)/flashed.md5 )

$(BUILDDIR)/$(MODULE)-netlist.json: $(MODULE).v $(DEPS) | $(BUILDDIR)

	yosys -p "prep -top $(MODULE); write_json $(BUILDDIR)/$(MODULE)-netlist.json" $(MODULE).v

$(BUILDDIR)/$(MODULE)-netlist-svg.json: $(MODULE).v $(DEPS) | $(BUILDDIR)

	yosys -DYOSYS_PLOT -q -p "prep -top $(MODULE); write_json -compat-int $(BUILDDIR)/$(MODULE)-netlist.json" $(MODULE).v

assets/$(MODULE).svg: $(BUILDDIR)/$(MODULE)-netlist-svg.json $(DEPS)

	netlistsvg $(BUILDDIR)/$(MODULE)-netlist.json -o assets/$(MODULE).svg

assets/$(MODULE)_dot.svg: $(MODULE).v $(DEPS)

	$(YOSYS) -DYOSYS_PLOT -q -p "read_verilog $(MODULE).v; hierarchy -check; proc; opt; fsm; opt; memory; opt; clean; stat; show -colors 1 -format svg -stretch -prefix $(MODULE)_dot $(MODULE);"
	mv $(MODULE)_dot.svg assets/
	[ -f $(MODULE)_dot.dot ] && rm $(MODULE)_dot.dot

$(MUSTACHE_GENERATED): $(wildcard mustache/*.mustache) mustache/modules.yaml
	@echo Generating mustache $@
	cd mustache && ./mkPipe.py

# We save AUXFILES names to build.config. Force a rebuild if they have changed
$(BOARD_BUILDDIR)/build.config: $(AUXFILES) .force | $(BUILDDIR)
	@echo '$(AUXFILES)' | cmp -s - $@ || echo '$(AUXFILES)' > $@

$(BUILDDIR):
	mkdir -p $(BUILDDIR)

$(BOARD_BUILDDIR)/top_wrapper.v: top_wrapper.m4 $(BOARD_BUILDDIR)/build.config
	m4 $(M4_OPTIONS) top_wrapper.m4 > $(BOARD_BUILDDIR)/top_wrapper.v

test:
	$(MAKE) -C test all

clean:
	rm -rf $(BOARD_BUILDDIR) $(BUILDDIR) $(CLEAN_PROGRAM) $(MUSTACHE_GENERATED) *.v.d

.PHONY: all clean json vcd svg bin sim dot .force test upload lint
