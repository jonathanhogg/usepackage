#! /bin/sh

# Usepackage Environment Manager
# Copyright (C) 1995-2003  Jonathan Hogg  <jonathan@onegoodidea.com>
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

echo "aclocal"
aclocal || exit $?

echo "autoconf"
autoconf || exit $?

echo "autoheader"
autoheader || exit $?

echo "automake --add-missing --copy"
automake --add-missing --copy || exit $?

