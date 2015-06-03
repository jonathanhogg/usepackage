# Usepackage Environment Manager
# Copyright (C) 1995-2015  Jonathan Hogg  <me@jonathanhogg.com>
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
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

bin_PROGRAMS = usepackage
usepackage_SOURCES = grammar.y match.c usepackage.c linked_list.c \
	scanner.l utils.c linked_list.h package.h utils.h use.bsh.in \
	use.csh.in use.ksh.in use.1.in usepackage.1.in
man_MANS = use.1 usepackage.1
pkgdata_DATA = use.bsh use.csh use.ksh
EXTRA_DIST = usepackage.conf

CLEANFILES = use.1 use.bsh use.csh use.ksh use.html usepackage.html
MAINTAINERCLEANFILES = grammar.c scanner.c configure Makefile.in \
	depcomp install-sh missing mkinstalldirs aclocal.m4 config.log \
	config.status config.h.in use.1 usepackage.1

AM_YFLAGS = -d
AM_CPPFLAGS = -DDEFAULT_PACKAGE_PATH='"$(sysconfdir):~:."'

SUBS = "s,\@pkgdatadir\@,$(pkgdatadir),;s,\@bindir\@,$(bindir),;s,\@sysconfdir\@,$(sysconfdir),"

use.1: use.1.in
	$(SED) $(SUBS) < use.1.in > use.1

usepackage.1: usepackage.1.in
	$(SED) $(SUBS) < usepackage.1.in > usepackage.1

use.html: use.1
	$(RMAN) -S -f HTML -r '%s.html' use.1 > use.html

usepackage.html: usepackage.1
	$(RMAN) -S -f HTML -r '%s.html' usepackage.1 > usepackage.html

use.bsh: use.bsh.in
	$(SED) $(SUBS) < use.bsh.in > use.bsh

use.csh: use.csh.in
	$(SED) $(SUBS) < use.csh.in > use.csh

use.ksh: use.ksh.in
	$(SED) $(SUBS) < use.ksh.in > use.ksh

install-data-local: usepackage.conf
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(sysconfdir)
	@if test -f $(DESTDIR)$(sysconfdir)/usepackage.conf; \
	 then \
	   echo " *** Existing usepackage.conf file, leaving it alone. ***"; \
	 else \
	   echo " $(INSTALL_DATA) usepackage.conf $(DESTDIR)$(sysconfdir)/"; \
	   $(INSTALL_DATA) usepackage.conf $(DESTDIR)$(sysconfdir)/; \
	 fi

html: use.html usepackage.html

