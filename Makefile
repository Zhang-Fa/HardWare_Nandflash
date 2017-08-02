objs := head.o init.o nandflash.o main.o

nandflash.bin : $(objs) 
	arm-linux-ld -Tnandflash.lds	-o nandflash_elf $^
	arm-linux-objcopy -O binary -S nandflash_elf $@
	arm-linux-objdump -D -m arm  nandflash_elf > nandflash.dis

#head.o:head.S
#	arm-linux-gcc -Wall -c head.S
#init.o:init.c
#	arm-linux-gcc -Wall -c init.c
#nandflash.o:nandflash.c nandflash.h
#	arm-linux-gcc -Wall -c nandflash.c
#main.o:main.c 
#	arm-linux-gcc -Wall -c main.c
%.o:%.c
	arm-linux-gcc -Wall -c -O2 -o $@ $<
%.o:%.S
	arm-linux-gcc -Wall -c -O2 -o $@ $<
%.o:%.c %.h
	arm-linux-gcc -Wall -c -O2 -o $@ $<
clean:
	rm -f  nandflash.dis nandflash.bin nandflash_elf *.o
