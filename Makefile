
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

HW_OS := $(shell /usr/local/gnu/bin/hw_os )

ifdef INSTALL_IN

CC = gcc -O2 -DMAIN_PACKAGE_FILE=\"$(INSTALL_IN)/lib/packages\"

install: noobjects README usepackage packages use.bsh use.csh use.ksh use.zsh
	$(INSTALL_DIR) $(INSTALL_IN)
	$(INSTALL_FILE) README $(INSTALL_IN)/README
	$(INSTALL_DIR) $(INSTALL_IN)/bin
	$(INSTALL_SCRIPT) use.bsh $(INSTALL_IN)/use.bsh
	$(INSTALL_SCRIPT) use.csh $(INSTALL_IN)/use.csh
	$(INSTALL_SCRIPT) use.ksh $(INSTALL_IN)/use.ksh
	$(INSTALL_SCRIPT) use.zsh $(INSTALL_IN)/use.zsh
	$(STRIP) usepackage
	$(INSTALL_DIR) $(INSTALL_IN)/bin/$(HW_OS)
	$(INSTALL_EXEC) usepackage $(INSTALL_IN)/bin/$(HW_OS)/usepackage
	$(INSTALL_DIR) $(INSTALL_IN)/lib
	$(INSTALL_FILE) packages $(INSTALL_IN)/lib/packages

%: %.in
	$(M4) -DINSTALL_DIR=$(INSTALL_IN) $*.in > $*

else

CC = gcc -g

endif

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

%.o: %.c
	$(CC) -c $*.c

noobjects:
	$(RM) *.o README use.bsh use.csh use.ksh use.zsh

clean: noobjects
	$(RM) scanner.c grammar.c grammar.h usepackage \


linked_list.o: linked_list.h
match.o: packages.h linked_list.h
usepackage.o: packages.h linked_list.h utils.h version.h
grammar.o: packages.h linked_list.h utils.h
scanner.o: packages.h grammar.h

