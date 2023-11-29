TARGET=agra.out
OBJ=agra_main.o framebuffer.o agra.o

# Bez optimizācijām, visus brīdinājumus
CCFLAGS=-g -mcpu=xscale -O0 -Wall
ASFLAGS=-a=$*.lis

CC=arm-linux-gnueabi-gcc
AS=arm-linux-gnueabi-as

all: build test

# Kompilēt un pēc tam salinkot % norāda uz to pašu $< paņem prasīto failu $@ (tas pats kas mērķis)
%.o: %.c
	$(CC) $(CCFLAGS) -c -o $@ $<

# Dolārs zvaigzne paņem mērķa nosaukumu bez paplašinājuma
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

build: $(OBJ)
	$(CC) -o $(TARGET) $(OBJ)

test: $(TARGET)
	qemu-arm -L /usr/arm-linux-gnueabi $(TARGET)

# Iztīrīt bez brīdinājuma
clean:
	rm -f *.o *.lis
	rm -f $(TARGET)