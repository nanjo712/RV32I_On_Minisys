COMPILER = riscv64-linux-gnu-
CC = $(COMPILER)gcc
LD = $(COMPILER)ld
AR = $(COMPILER)ar
OBJCOPY = $(COMPILER)objcopy
OBJDUMP = $(COMPILER)objdump
READELF = $(COMPILER)readelf

CFLAGS += -Wall -O2 -Werror -march=rv32i -mabi=ilp32 -nostdlib \
	-ffunction-sections -fdata-sections
