
# Makefile

usepackage: usepackage.o linked_list.o grammar.o scanner.o match.o
	gcc -o usepackage usepackage.o linked_list.o grammar.o scanner.o \
	    match.o
	strip usepackage

grammar.c grammar.h: grammar.y linked_list.h packages.h
	bison -d grammar.y
	mv grammar.tab.c grammar.c
	mv grammar.tab.h grammar.h

scanner.c: scanner.l linked_list.h grammar.h packages.h
	flex -Cf -i scanner.l
	mv lex.yy.c scanner.c

%.o: %.c
	gcc -O2 -c $*.c

clean:
	rm -f *.o scanner.c grammar.c grammar.h usepackage


linked_list.o: linked_list.h
match.o: packages.h linked_list.h
usepackage.o: packages.h linked_list.h

