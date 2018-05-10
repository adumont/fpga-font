# call with make MODULE=moduleName sim|svg|upload

ifndef $(MODULE)
	MODULE=top
endif
ifeq ($(MODULE), top)
  DEPS:=\
    font.v \
    tilemem.v \
    ram.v \
    vga_sync.v

  AUXFILES:=\
    ram.list\
    ram65.list\
	const.vh

# YOSYSOPT:=-retime -abc2
endif

ifndef $(MEMORY)
	MEMORY="1k"
endif

all: bin

bin: $(MODULE).bin
sim: $(MODULE)_tb.vcd
json: $(MODULE).json
svg: assets/$(MODULE).svg

$(MODULE)_tb.vcd: $(MODULE).v $(DEPS) $(MODULE)_tb.v  $(AUXFILES)

	iverilog $^ -o $(MODULE)_tb.out
	./$(MODULE)_tb.out
	gtkwave $@ $(MODULE)_tb.gtkw &

$(MODULE).bin: $(MODULE).pcf $(MODULE).v $(DEPS) $(AUXFILES)
	
	yosys -p "synth_ice40 -blif $(MODULE).blif $(YOSYSOPT)"\
              -l $(MODULE).log -q $(MODULE).v $(DEPS)
	
	arachne-pnr -d $(MEMORY) -p $(MODULE).pcf $(MODULE).blif -o $(MODULE).pnr
	
	icepack $(MODULE).pnr $(MODULE).bin

$(MODULE).json: $(MODULE).v $(DEPS)
	yosys -p "prep -top $(MODULE); write_json $(MODULE).json" $(MODULE).v $(DEPS)

assets/$(MODULE).svg: $(MODULE).json
	netlistsvg $(MODULE).json -o assets/$(MODULE).svg

upload: $(MODULE).bin
	iceprog $(MODULE).bin

clean:
	rm -f *.bin *.pnr *.blif *.out *.vcd *~

.PHONY: all clean json svg sim
