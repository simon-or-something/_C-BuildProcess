OUT := .build

.SECONDARY:	$(wildcard $(OUT)/*)
.PHONY: all clean

all: $(OUT)/main $(OUT)/rawprintf

clean:
	rm -f $(OUT)/*
	@# gcc -fdump-tree-all 

$(OUT)/main: $(OUT)/main.o # linking
	@# /lib64/ld-linux-x86-64.so.2 $^ -o $@ -lc /lib64/crt1.o # says "only ET_DYN and ET_EXEC can be loaded"

	@# while it is *possible* to statically link that isnt advised (dynamic then static demo)
	@# https://stackoverflow.com/questions/26304531
	@#ld $^ -o $@ -lc /lib64/crt1.o    # this links but the dependencies have to be linked dynamically
	@#/lib64/ld-linux-x86-64.so.2 ./$@ # done like this

	@# this is how it is, and should be done
	ld $< -o $@ -lc /usr/lib/x86_64-linux-gnu/crt1.o -dynamic-linker /lib64/ld-linux-x86-64.so.2

	@# this was another attempt which failed. it relies on gcc being dynamic
	@#ld -static /usr/lib64/crt1.o /usr/lib64/crti.o $(OUT)/main.o -L/usr/lib/gcc/x86_64-linux-gnu -lc -lgcc -lgcc_eh /usr/lib/x86_64-linux-gnu/crtn.o -o main -lc

$(OUT)/rawprintf: $(OUT)/rawprintf.o
	@# you dont have to call the linker here because this is a raw file
	@# you would have to if you link with crt1.o
	ld $< -o $@

main.c: $(OUT)/header.h.gch

$(OUT)/%.d : %.c # dependency files
	echo "" > $@

$(OUT)/%.i : %.c $(OUT)/%.d # pre processor
	cpp -E -dD $< -o $@

$(OUT)/%.s: $(OUT)/%.i # assembly output (with gcc: `gcc -S main.i -o main.s`)
	/usr/libexec/gcc/x86_64-linux-gnu/14/cc1 $^ -o $@

$(OUT)/%.o : $(OUT)/%.s # compilation (assembly)
	as -c $^ -o $@

$(OUT)/%.h.gch: %.h
	mkdir -p $(OUT)
	gcc -c $^ -o $@

# -include *.d
