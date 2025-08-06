BIN0 = obj_dir/VTrafficLightController

INCLUDE := -Isrc
VFLAGS := -Wall --cc --exe --build --trace
VC := verilator

.PHONY: all clean format run wave

all: $(BIN0)

wave:
	mkdir -p $@

run: tb0
tb0: $(BIN0) | wave
	./$<

obj_dir/V%: src/%.sv tb/%.cpp
	$(VC) $(VFLAGS) $(INCLUDE) $^

format:
	clang-format -i tb/*.cpp

clean:
	$(RM) -rv obj_dir wave
