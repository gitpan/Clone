# $Id: Clone.pm,v 0.8 2000/08/11 17:08:24 ray Exp $
#
# $Log: Clone.pm,v $
# Revision 0.8  2000/08/11 17:08:24  ray
# Release 0.08.
#
# Revision 0.7.2.1  2000/08/11 16:35:09  ray
# added linke to Storable(3), removed C++ style comments.
#
# Revision 0.7  2000/08/01 00:31:24  ray
# release 0.07.
#
# Revision 0.6.2.6  2000/08/01 00:26:10  ray
# added Optimization for inline functions.
#
# Revision 0.6.2.5  2000/07/31 18:37:03  ray
# added support for tied objects.
#
# Revision 0.6.2.4  2000/07/28 20:40:25  ray
# added support for circular references
#
# Revision 0.6.2.3  2000/07/28 19:04:14  ray
# first pass at circular references.
#
# Revision 0.6.2.2  2000/07/28 18:54:33  ray
# added support for scalar types.
#
#
package Clone;

use strict;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();
@EXPORT_OK = qw( clone );

$VERSION = '0.08';

bootstrap Clone $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Clone - Perl extension for a recurrsive copy of nested objects.

=head1 SYNOPSIS

  use Clone;
  
  push @Package::A::ISA, 'Clone';

  $a = new Package::A;
  $b = $a->clone;
  
  # or
  use Clone qw(clone);

  $b = clone($a,1);

=head1 DESCRIPTION

The Clone module provides a clone method for making recursive
copies of nested hash, array, and scalar objects, as well as
tied variables. An optional parameter can be used to limit the 
depth of the copy.

=head1 AUTHOR

Ray Finch, ray@classmates.com

Copyright 2000 Ray Finch.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Storable(3).

=cut
