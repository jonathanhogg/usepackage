
usepackage: usepackage.o linked_list.o grammar.o scanner.o
	gcc -o usepackage usepackage.o linked_list.o grammar.o scanner.o -lfl

grammar.c grammar.h: grammar.y linked_list.h packages.h
	bison -d grammar.y
	mv grammar.tab.c grammar.c
	mv grammar.tab.h grammar.h

scanner.c: scanner.l linked_list.h grammar.h packages.h
	flex scanner.l
	mv lex.yy.c scanner.c

linked_list.c: linked_list.h

%.o: %.c
	gcc -c $*.c

clean:
	rm -f *.o scanner.c grammar.c grammar.h usepackage

