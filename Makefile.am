
bin_PROGRAMS = usepackage
usepackage_SOURCES = grammar.y match.c usepackage.c linked_list.c \
	scanner.l utils.c linked_list.h package.h.in utils.h use.bsh.in \
	use.csh.in use.ksh.in use.1.in
man_MANS = use.1
pkgdata_DATA = use.bsh use.csh use.ksh
dist_sysconf_CONF = usepackage.conf
CLEANFILES = use.1 use.bsh use.csh use.ksh
MAINTAINERCLEANFILES = grammar.c scanner.c configure Makefile.in \
	depcomp install-sh missing mkinstalldirs
AM_YFLAGS = -d

%: %.in
	$(SED) "s,\@pkgdatadir\@,$(pkgdatadir),;s,\@bindir\@,$(bindir),;s,\@sysconfdir\@,$(sysconfdir)," < $*.in > $*
	
