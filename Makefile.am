
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
	config.status 

AM_YFLAGS = -d
AM_CPPFLAGS = -DDEFAULT_PACKAGE_PATH='"$(sysconfdir):~:."'

%: %.in
	$(SED) "s,\@pkgdatadir\@,$(pkgdatadir),;s,\@bindir\@,$(bindir),;s,\@sysconfdir\@,$(sysconfdir)," < $*.in > $*

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

