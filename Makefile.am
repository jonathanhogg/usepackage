
bin_PROGRAMS = usepackage
usepackage_SOURCES = grammar.y match.c usepackage.c linked_list.c \
	scanner.l utils.c linked_list.h package.h utils.h use.bsh.in \
	use.csh.in use.ksh.in use.1.in
man_MANS = use.1
pkgdata_DATA = use.bsh use.csh use.ksh
EXTRA_DIST = usepackage.conf

CLEANFILES = use.1 use.bsh use.csh use.ksh
MAINTAINERCLEANFILES = grammar.c scanner.c configure Makefile.in \
	depcomp install-sh missing mkinstalldirs aclocal.m4 config.log \
	config.status config.h.in

AM_YFLAGS = -d
AM_CPPFLAGS = -DDEFAULT_PACKAGE_PATH='"$(sysconfdir):~:."'

SUBS = "s,\@pkgdatadir\@,$(pkgdatadir),;s,\@bindir\@,$(bindir),;s,\@sysconfdir\@,$(sysconfdir),"

use.1: use.1.in
	$(SED) $(SUBS) < use.1.in > use.1

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

