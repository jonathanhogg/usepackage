#
# FP group packages
#
# Version: $Revision$
#
# [see packages.master]
#

FP * * * * :            PATH += /local/fp/bin,
                        MANPATH += /local/fp/man ;
FP sun4* SunOS 4.* * :  PATH += /local/fp/bin/sparc-sun-sunos4 ;
FP sun4* SunOS 5.* * :  PATH += /local/fp/bin/sparc-sun-solaris2 ;
FP alpha OSF1 * * :     PATH += /local/fp/bin/alpha-dec-osf2 ;
FP i86pc SunOS 5.* * :  PATH += /local/fp/bin/i386-unknown-solaris2 ;

