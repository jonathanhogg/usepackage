
# Makefile

LINK = gcc
INSTALL_EXEC = install -m 711
INSTALL_SCRIPT = install -m 755
INSTALL_FILE = install -m 644 
INSTALL_DIR = install -m 755 -d
M4 = m4
STRIP = strip
BISON = bison -d
FLEX = flex -Cf -i
MV = mv
RM = rm -f

ifdef INSTALL_IN

CC = gcc -O2 -DMAIN_PACKAGE_FILE=\"$(INSTALL_IN)/lib/packages\"

target: install

else

CC = gcc -g

target: usepackage

endif


install: noobjects README usepackage packages usepackage.sh
	$(INSTALL_DIR) $(INSTALL_IN)
	$(INSTALL_FILE) README $(INSTALL_IN)/README
	$(INSTALL_DIR) $(INSTALL_IN)/bin
	$(INSTALL_SCRIPT) usepackage.sh $(INSTALL_IN)/bin/usepackage 
	$(STRIP) usepackage
	$(INSTALL_DIR) $(INSTALL_IN)/bin/$(ARCH)
	$(INSTALL_EXEC) usepackage $(INSTALL_IN)/bin/$(ARCH)/usepackage
	$(INSTALL_DIR) $(INSTALL_IN)/lib
	$(INSTALL_FILE) packages $(INSTALL_IN)/lib/packages

usepackage: usepackage.o linked_list.o grammar.o scanner.o match.o
	$(LINK) -o usepackage usepackage.o linked_list.o grammar.o scanner.o \
	    match.o

README: README.in
	$(M4) -DINSTALL_DIR=$(INSTALL_IN) README.in > README

usepackage.sh: usepackage.sh.in
	$(M4) -DINSTALL_DIR=$(INSTALL_IN) usepackage.sh.in > usepackage.sh

grammar.c grammar.h: grammar.y linked_list.h packages.h
	$(BISON) grammar.y
	$(MV) grammar.tab.c grammar.c
	$(MV) grammar.tab.h grammar.h

scanner.c: scanner.l linked_list.h grammar.h packages.h
	$(FLEX) scanner.l
	$(MV) lex.yy.c scanner.c

%.o: %.c
	$(CC) -c $*.c

noobjects:
	$(RM) *.o

clean:
	$(RM) *.o scanner.c grammar.c grammar.h usepackage usepackage.sh \
		README


linked_list.o: linked_list.h
match.o: packages.h linked_list.h
usepackage.o: packages.h linked_list.h version.h

