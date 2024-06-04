#!/usr/bin/env raku

use File::Find;
use JSON::Hjson;
use JSON::Fast;
#use JSON::Class:auth<zef:vrurg>;
use JSON::Class:auth<zef:jonathanstowe>;

my $dir = "../resources";
my @yfils = find :$dir, :type<file>, :name(/:i '.' [yml|yaml] $/);
my @jfils = find :$dir, :type<file>, :name(/:i '.' [json] $/);
my @hfils = find :$dir, :type<file>, :name(/:i '.' [hjson] $/);

say "../resources files:";
say "  $_" for |@yfils, |@hfils, |@jfils;

# all hashes should have keys from the same set
# some MUST have keys from the same subset
sub get-yml-hash($f --> Hash) is export {} 
sub get-json-hash($f --> Hash) is export  {} 
sub get-hjson-hash($f --> Hash) is export  {} 
# handlers subroutines MUST be defined for all key types
# handlers may be auto-generated

exit;

#my $hj = "../resources/user-check-data.hjson";
#my $h = from-hjson(slurp $hj);
