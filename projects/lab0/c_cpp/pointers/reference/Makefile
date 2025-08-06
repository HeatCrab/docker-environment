BIN := main.exe

CXX := g++

CFLAGS := -Wall -Wextra -O2
INCLUDE_DIR := .

SRC := main.c
OBJ := $(SRC:.c=.o)

.PHONY: all run clean

all: $(BIN) run

$(BIN): $(OBJ)
	$(CXX) $^ -o $@

%.o: %.c
	$(CXX) -c $(CFLAGS) $< -I$(INCLUDE_DIR) -o $@

run: $(BIN)
	./$(BIN)

clean:
	rm -rf $(BIN) $(OBJ)
