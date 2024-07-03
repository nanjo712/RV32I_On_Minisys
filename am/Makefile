-include ../scripts/common.mk

SRCS = $(wildcard src/*.c) $(wildcard src/*.S)
OBJS = $(addprefix build/, $(addsuffix .o, $(basename $(notdir $(SRCS)))))

build/%.o: src/%.c
	mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@ -Iinclude

build/%.o: src/%.S
	mkdir -p build
	$(CC) $(CFLAGS) -c $< -o $@ -Iinclude

build/am.a: $(OBJS)
	mkdir -p build
	$(AR) rcs $@ $^

all: build/am.a

clean:
	rm -rf build

.PHONY: all clean