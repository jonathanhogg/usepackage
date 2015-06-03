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

AC_INIT(usepackage,1.13,me@jonathanhogg.com,usepackage)
AM_INIT_AUTOMAKE

AM_CONFIG_HEADER(config.h)
AC_PROG_CC
AM_PROG_LEX
AC_PROG_YACC
AC_CHECK_PROGS(SED,sed)
AC_CHECK_PROGS(INSTALL,install install-sh install.sh)
AC_CHECK_PROGS(RMAN,rman)
AC_CHECK_HEADER(stdio.h)
AC_CHECK_HEADER(stdlib.h)
AC_CHECK_HEADER(string.h)
AC_CHECK_HEADER(sys/utsname.h)
AC_CHECK_HEADER(dirent.h)

AH_VERBATIM([COPYRIGHT],
[/* Copyright string for the executable. */
#ifndef COPYRIGHT
# define COPYRIGHT "Copyright (C) 1995-2015  Jonathan Hogg  <me@jonathanhogg.com>"
#endif])

AC_OUTPUT(Makefile)
