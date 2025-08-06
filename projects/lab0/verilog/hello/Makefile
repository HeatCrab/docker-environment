SRC = Hello.v
BLDDIR = obj_dir
BIN = $(BLDDIR)/VHello

VFLAGS = -Wall -Mdir $(BLDDIR) --binary
VC = verilator

.PHONY: all clean format run

all: $(BIN)

run: $(BIN)
	./$<

$(BIN): $(SRC)
	$(VC) $(VFLAGS) $^

format:
	clang-format -i tb/*.cpp

clean:
	$(RM) -rv $(BLDDIR)
