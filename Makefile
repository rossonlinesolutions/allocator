# Allocator makefile
PHONY := all clean
CLEAN := target/*.o target/allocator.a

SRC_DIR := src
OBJ_DIR := target
SOURCES := $(wildcard $(SRC_DIR)/*.asm)
OBJECTS := $(patsubst $(SRC_DIR)/%.asm, $(OBJ_DIR)/%.o, $(SOURCES))
TARGET := $(OBJ_DIR)/allocator.a

all: $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	nasm -f elf64 -o $@ $<

$(TARGET): $(OBJECTS)
	ar rcs $@ $^

clean:
	rm -f $(CLEAN)

.PHONY: $(PHONY)