# $Id: 07magic.t,v 1.2 2005/04/20 15:49:35 ray Exp $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use Clone;
use Data::Dumper;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$^W = 0;
$test = 2;

sub ok     { printf("ok %d\n", $test++); }
sub not_ok { printf("not ok %d\n", $test++); }

use strict;

package main;

use Scalar::Util qw( weaken );

my $x = { a => "worked\n" }; 
my $y = $x;
weaken($y);
my $z = Clone::clone($x);
Dumper($x) eq Dumper($z) ? ok : not_ok;

# print Dumper($a, $b);
# print Dumper($a, $c);
