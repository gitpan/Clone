# $Id: 07magic.t,v 1.3 2006/03/06 06:59:40 ray Exp $

use strict;

use Clone;
use Test::More tests => 2;

SKIP: {
  eval "use Data::Dumper";
  skip "Data::Dumper not installed", 1 if $@;

  SKIP: {
    eval "use Scalar::Util qw( weaken )";
    skip "Scalar::Util not installed", 1 if $@;
  
    my $x = { a => "worked\n" }; 
    my $y = $x;
    weaken($y);
    my $z = Clone::clone($x);
    ok( Dumper($x) eq Dumper($z), "Cloned weak reference");
  }
}

SKIP: {
  eval "use Taint::Runtime qw(enable taint_env)";
  skip "Taint::Runtime not installed", 1 if $@;
  taint_env();
  my $x = "";
  for (keys %ENV)
  {
    $x = $ENV{$_};
    last if ( $x && length($x) > 0 );
  }
  my $y = Clone::clone($x);
  ## ok(Clone::clone($tainted), "Tainted input");
  ok( Dumper($x) eq Dumper($y), "Tainted input");
}
