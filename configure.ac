AC_INIT(usepackage,1.6.1,jonathan@onegoodidea.com,usepackage)
AM_INIT_AUTOMAKE(usepackage,1.6.1)

AM_CONFIG_HEADER(config.h)
AC_PROG_CC
AM_PROG_LEX
AC_PROG_YACC
AC_CHECK_PROGS(SED,sed)
AC_CHECK_PROGS(INSTALL,install install-sh install.sh)
AC_CHECK_HEADER(stdio.h)
AC_CHECK_HEADER(stdlib.h)
AC_CHECK_HEADER(string.h)
AC_CHECK_HEADER(sys/utsname.h)
AC_CHECK_HEADER(dirent.h)

AH_VERBATIM([COPYRIGHT],
[/* Copyright string for the executable. */
#ifndef COPYRIGHT
# define COPYRIGHT "Copyright 1995-2002 Jonathan Hogg"
#endif])

AC_OUTPUT(Makefile)
