entrega = src/hash.s src/hash.py LEIAME.txt docs/relatorio.pdf

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
	chmod u+r+x test-asm.sh
	chmod u+r+x test-py.sh

tar:
	mkdir ep1-ana_livia_saldanha
	cp $(entrega) ep1-ana_livia_saldanha/
	tar zcvf ep1-ana_livia_saldanha.tar.gz ep1-ana_livia_saldanha
	rm -r ep1-ana_livia_saldanha