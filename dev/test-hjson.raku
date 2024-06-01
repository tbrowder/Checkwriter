#!/usr/bin/env raku

use JSON::Hjson;
use JSON::Fast;
#use JSON::Class:auth<zef:vrurg>;
use JSON::Class:auth<zef:jonathanstowe>;

my $hj = "../resources/user-check-data.hjson";
my $h = from-hjson(slurp $hj);
for $h.kv -> $k,$v {
    say "key: $k";
    say "  val: $v";
}

=finish

my $hj = q:to/HERE/;
{
  top: 3
  left: 4
}
HERE

my $hash = from-hjson $hj;
say $hash.raku;

my $json = to-json $hash;
say $json.raku;

my $jfil = "t.json";
spurt $jfil, $json;

# the class scalar attrs map to those in the
# appropriate hjson-foramatted data file
class O does JSON::Class {
    has $.top;
    has $.left;
}

my $o = O.from-json: slurp($jfil);
say $o.top;
say $o.left;



