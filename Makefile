PHONY := all clean
CLEAN := target

SRC_DIR := src
OBJ_DIR := target
SOURCES := $(wildcard $(SRC_DIR)/*.asm)
OBJECTS := $(patsubst $(SRC_DIR)/%.asm, $(OBJ_DIR)/%.o, $(SOURCES))
TARGET := $(OBJ_DIR)/allocator.a

NASM_FLAGS :=
CC_FLAGS :=

ifdef DEBUG
NASM_FLAGS += -g
CC_FLAGS += -g
endif

all: $(TARGET)

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm | $(OBJ_DIR)
	nasm -f elf64 $(NASM_FLAGS) -o $@ $<

$(TARGET): $(OBJECTS)
	ar rcs $@ $^

clean:
	rm -rf $(CLEAN)

CLEAN += Example1
Example1: $(TARGET)
	gcc $(CC_FLAGS) -o Example1 examples/example1.c target/allocator.a

.PHONY: $(PHONY)
