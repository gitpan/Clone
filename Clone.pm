# $Id: Clone.pm,v 0.10 2001/04/29 22:14:01 ray Exp $
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

( $VERSION ) = '$Revision: 0.10 $ ' =~ /\$Revision:\s+([^\s]+)/;

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

Ray Finch, rdf@cpan.org

Copyright 2000 Ray Finch.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Storable(3).

=cut
