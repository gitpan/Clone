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

$VERSION = '0.06';

bootstrap Clone $VERSION;

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is the stub of documentation for your module. You better edit it!

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

The Clone module provides a clone function for making recursive
copies of nested hash and array objects. It was written as an XSUB
for speed and can be called as a function or a method.

=head1 AUTHOR

Ray Finch, ray@classmates.com

=head1 SEE ALSO

perl(1).

=cut
