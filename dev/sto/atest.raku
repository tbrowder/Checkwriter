#!/bin/env raku

use JSON::Hjson;
use JSON::Fast;

my $debug = 0;

my $hj = "data/Check.hjson";
my $hash = from-hjson $hj.IO.slurp;
say $hash.raku if $debug;
my $json = to-json $hash;
say $json.raku;
my $jfil = "t.json";
spurt $jfil, $json;
