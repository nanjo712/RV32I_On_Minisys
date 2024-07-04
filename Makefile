-include scripts/common.mk

IMAGE = 

LDFLAGS += -T scripts/linker.ld -melf32lriscv \
	--defsym=_pmem_start=0x80000000 -e _start --gc-sections --print-map

LIBS = am

all: build/$(IMAGE).bin build/$(IMAGE).txt build/$(IMAGE).elf target.coe

test/build/$(IMAGE).o: test/srcs/$(IMAGE).c
	mkdir -p test/build
	$(CC) $(CFLAGS) -c $< -o $@

build/$(IMAGE).elf: $(LIBS)/build/$(LIBS).a test/build/$(IMAGE).o
	mkdir -p build
	$(LD) $(LDFLAGS) -o $@ $^

build/$(IMAGE).txt: build/$(IMAGE).elf
	$(OBJDUMP) -d $< > $@

build/$(IMAGE).bin: build/$(IMAGE).elf
	mkdir -p build
	$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $< $@

target.coe: build/$(IMAGE).bin
	util/bin2coe $< $@

clean:
	rm -rf build test/build
