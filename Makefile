
# Makefile


GROUP = contrib
DEST = /usr/local/contrib
PACKAGE_FILES = packages.master packages.vlsi packages.fp packages.rapids \
		packages.contrib
MASTER_PACKAGE_FILE = packages.master
DEFAULT_PACKAGE_PATH = $(DEST)/lib/usepackage:~:.


INSTALL_EXEC = install -m 771 -g $(GROUP)
INSTALL_SCRIPT = install -m 775 -g $(GROUP)
INSTALL_FILE = install -m 664 -g $(GROUP)
INSTALL_DIR = install -m 775 -d -g $(GROUP)
M4 = m4
STRIP = strip
BISON = bison -d
FLEX = flex -Cf -i
MV = mv
RM = rm -f
CC = gcc -O2 -DDEFAULT_PACKAGE_PATH=\"$(DEFAULT_PACKAGE_PATH)\" \
	-DMASTER_PACKAGE_FILE=\"$(MASTER_PACKAGE_FILE)\"
LINK = gcc


all: README usepackage use.bsh use.csh use.ksh use.zsh

install: install-exec install-packages

install-exec: usepackage
	$(STRIP) usepackage
	$(INSTALL_EXEC) usepackage $(DEST)/bin/usepackage

install-lib: README use.bsh use.csh use.ksh use.zsh
	$(INSTALL_DIR) $(DEST)/lib/usepackage
	$(INSTALL_FILE) README $(DEST)/lib/usepackage/README
	$(INSTALL_SCRIPT) use.bsh $(DEST)/lib/usepackage/use.bsh
	$(INSTALL_SCRIPT) use.csh $(DEST)/lib/usepackage/use.csh
	$(INSTALL_SCRIPT) use.ksh $(DEST)/lib/usepackage/use.ksh
	$(INSTALL_SCRIPT) use.zsh $(DEST)/lib/usepackage/use.zsh
	for package in $(PACKAGE_FILES) ;\
	do \
		$(INSTALL_FILE) $$package $(DEST)/lib/usepackage/$$package ;\
	done

OBJECTS = usepackage.o grammar.o scanner.o linked_list.o utils.o match.o

usepackage: $(OBJECTS)
	$(LINK) -o usepackage $(OBJECTS)

grammar.c grammar.h: grammar.y
	$(BISON) grammar.y
	$(MV) grammar.tab.c grammar.c
	$(MV) grammar.tab.h grammar.h

scanner.c: scanner.l
	$(FLEX) scanner.l
	$(MV) lex.yy.c scanner.c

clean:
	$(RM)	README usepackage use.bsh use.csh use.ksh use.zsh \
		$(OBJECTS) scanner.c grammar.c grammar.h

%.o: %.c
	$(CC) -c $*.c

%: %.in
	$(M4) -DINSTALL_DIR=$(DEST) $*.in > $*


linked_list.o: linked_list.h
match.o: package.h linked_list.h
usepackage.o: package.h linked_list.h utils.h version.h
grammar.o: package.h linked_list.h utils.h
scanner.o: package.h grammar.h

