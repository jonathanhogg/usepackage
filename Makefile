
### Makefile ###


#--- edit these variables to customise (or supply them as make args) ---#


# Installation root:

ifndef(prefix)
prefix = /usr/local/contrib
endif

# Install group:

GROUP = contrib

# List of package spec files to install:

PACKAGE_FILES = packages.master packages.vlsi packages.fp packages.rapids \
		packages.contrib

# Which package spec file to load first:

MASTER_PACKAGE_FILE = packages.master

# Path for finding package specs:

DEFAULT_PACKAGE_PATH = $(prefix)/lib/usepackage:~:.


#--- usual stuff about not editing below this line unless you're sure ---#


CC = gcc
CCOPTS = -O2 -DDEFAULT_PACKAGE_PATH=\"$(DEFAULT_PACKAGE_PATH)\" \
	-DMASTER_PACKAGE_FILE=\"$(MASTER_PACKAGE_FILE)\"
LINK = gcc

M4 = m4
STRIP = strip
BISON = bison -d
FLEX = flex -Cf -i
MV = mv
RM = rm -f

INSTALL_EXEC = install -m 771 -g $(GROUP)
INSTALL_SCRIPT = install -m 775 -g $(GROUP)
INSTALL_FILE = install -m 664 -g $(GROUP)
INSTALL_DIR = install -m 775 -d -g $(GROUP)


#--- and below this line only if you're *really* sure what you're doing ---#


all: README usepackage use.bsh use.csh use.ksh use.man

install: install-exec install-lib install-man

install-exec: usepackage
	$(STRIP) usepackage
	$(INSTALL_EXEC) usepackage $(DEST)/bin/usepackage

install-lib: README use.bsh use.csh use.ksh
	$(INSTALL_DIR) $(DEST)/lib/usepackage
	$(INSTALL_FILE) README $(DEST)/lib/usepackage/README
	$(INSTALL_SCRIPT) use.bsh $(DEST)/lib/usepackage/use.bsh
	$(INSTALL_SCRIPT) use.csh $(DEST)/lib/usepackage/use.csh
	$(INSTALL_SCRIPT) use.ksh $(DEST)/lib/usepackage/use.ksh
	for package in $(PACKAGE_FILES) ;\
	do \
		$(INSTALL_FILE) $$package $(DEST)/lib/usepackage/$$package ;\
	done

install-man: use.man
	$(INSTALL_FILE) use.man $(DEST)/man/man1/use.1

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
	$(RM)	README usepackage use.bsh use.csh use.ksh use.man \
		$(OBJECTS) scanner.c grammar.c grammar.h

%.o: %.c
	$(CC) $(CCOPTS) -c $*.c

%: %.in
	$(M4) -DINSTALL_DIR=$(DEST) $*.in > $*


linked_list.o: linked_list.h
match.o: package.h linked_list.h
usepackage.o: package.h linked_list.h utils.h version.h
grammar.o: package.h linked_list.h utils.h
scanner.o: package.h grammar.h

