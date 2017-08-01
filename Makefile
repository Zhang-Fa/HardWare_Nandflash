objs := head.o init.o nandflash.o main.o

nand.bin : $(objs)
	arm-linux-ld -Tnandflash.lds	-o nandflash_elf $^
	arm-linux-objcopy -O binary -S nandflash_elf $@
	arm-linux-objdump -D -m arm  nandflash_elf > nandflash.dis

%.o:%.c %.h
	arm-linux-gcc -Wall -c -O2 -o $@ $<

%.o:%.S
	arm-linux-gcc -Wall -c -O2 -o $@ $<

clean:
	rm -f  nandflash.dis nandflash.bin nandflash_elf *.o
