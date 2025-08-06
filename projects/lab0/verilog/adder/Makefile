BIN0 = obj_dir/VFullAdder
BIN1 = obj_dir/VRippleCarryAdder

INCLUDE := -Isrc
VFLAGS := --Wno-UNOPTFLAT --cc --exe --build --trace 
VC := verilator

.PHONY: all clean format run

all: $(BIN0) $(BIN1)

wave:
	mkdir -p $@

run: tb0 tb1
tb0: $(BIN0) | wave
	./$<
tb1: $(BIN1) | wave
	./$<

obj_dir/V%: src/%.sv tb/%.cpp
	$(VC) $(VFLAGS) $(INCLUDE) $^

format:
	clang-format -i tb/*.cpp

clean:
	$(RM) -rv obj_dir wave
