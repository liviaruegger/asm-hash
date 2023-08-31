assemble:
	nasm -f elf64 src/hash.s
	ld -s -o hash src/hash.o
	rm src/hash.o
	mv hash exec/

test-asm: assemble
	./test/test-asm.sh

test-py:
	./test/test-py.sh

permission:
	chmod u+r+x test-py.sh