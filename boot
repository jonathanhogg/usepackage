#! /bin/sh

echo "aclocal"
aclocal || exit $?

echo "autoconf"
autoconf || exit $?

echo "autoheader"
autoheader || exit $?

echo "automake --add-missing --copy"
automake --add-missing --copy || exit $?

