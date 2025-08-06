ELF_NAME := main

GCC := g++

CFLAGS := -Wall -Wextra -O2
INCLUDE_DIR := .

SRC := main.c
OBJ := $(SRC:.c=.o)

.PHONY: all run clean

all: $(ELF_NAME) run

$(ELF_NAME): $(OBJ)
	$(GCC) $^ -o $@

%.o: %.c
	$(GCC) -c $(CFLAGS) $< -I$(INCLUDE_DIR) -o $@

run: $(ELF_NAME)
	./$(ELF_NAME)

clean:
	rm -rf $(ELF_NAME) $(OBJ)
