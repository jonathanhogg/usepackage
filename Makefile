##############################################################################
# 
# Copyright (C) 2001 Jonathan Hogg
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
# 
# Name   : Makefile
# Author : Jonathan Hogg <jonathan@dcs.gla.ac.uk>
# 
##############################################################################


### Makefile ###

#--- edit these variables to customise (or supply them as make args) ---#


# Installation root:

ifndef prefix
prefix = /usr/local/contrib
endif

# Install group:

GROUP = contrib

# List of package spec files to install:

PACKAGE_FILES = packages.master packages.vlsi packages.fp packages.rapids \
		packages.contrib packages.our

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


all: README usepackage use.bsh use.csh use.ksh use.1

install: install-exec install-lib install-man

install-exec: usepackage
	$(STRIP) usepackage
	$(INSTALL_DIR) $(prefix)/bin
	$(INSTALL_EXEC) usepackage $(prefix)/bin/usepackage

install-lib: README use.bsh use.csh use.ksh
	$(INSTALL_DIR) $(prefix)/lib/usepackage
	$(INSTALL_FILE) README $(prefix)/lib/usepackage/README
	$(INSTALL_SCRIPT) use.bsh $(prefix)/lib/usepackage/use.bsh
	$(INSTALL_SCRIPT) use.csh $(prefix)/lib/usepackage/use.csh
	$(INSTALL_SCRIPT) use.ksh $(prefix)/lib/usepackage/use.ksh
	for package in $(PACKAGE_FILES) ;\
	do \
		$(INSTALL_FILE) $$package $(prefix)/lib/usepackage/$$package ;\
	done

install-man: use.1
	$(MKDIR_P) $(DEST)/man/man1
	$(INSTALL_FILE) use.1 $(DEST)/man/man1

OBJECTS = usepackage.o grammar.o scanner.o linked_list.o utils.o match.o

usepackage: $(OBJECTS)
	$(LINK) $(LDFLAGS) -o usepackage $(OBJECTS)

grammar.c grammar.h: grammar.y
	$(BISON) grammar.y
	$(MV) grammar.tab.c grammar.c
	$(MV) grammar.tab.h grammar.h

scanner.c: scanner.l
	$(FLEX) scanner.l
	$(MV) lex.yy.c scanner.c

clean:
	$(RM)	README usepackage use.bsh use.csh use.ksh use.1 \
		$(OBJECTS) scanner.c grammar.c grammar.h

%.o: %.c
	$(CC) $(CFLAGS) $(DEFINES) -c $*.c

%: %.in
	$(M4) -DINSTALL_DIR=$(DEST) \
	      -DMASTER_PACKAGE_FILE=$(MASTER_PACKAGE_FILE) $*.in > $*


linked_list.o: linked_list.h
match.o: package.h linked_list.h
usepackage.o: package.h linked_list.h utils.h version.h
grammar.o: package.h linked_list.h utils.h
scanner.o: package.h grammar.h

