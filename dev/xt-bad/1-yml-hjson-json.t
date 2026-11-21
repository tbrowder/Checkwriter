use v6;
use Test;

use JSON::Hjson;
use JSON::Fast;
use YAMLish;

my ($y1, $y2, $h1, $j1);
$y1 = "resources/config.yml";
$y2 = "resources/account.yml";
$h1 = "resources/check.hjson";
$j1 = "resources/register.json";

# yaml files
my %y1 = load-yaml $y1.IO.slurp;
isa-ok %y1, Hash;
# account data
#   key => value
my %y2 = load-yaml $y2.IO.slurp;
isa-ok %y2, Hash;
for %y2.kv -> $k, $v {
    if $k.contains("-symbol") {
        is $v, '$', "YAML handles trailing comments"; 
    }
}

# hjson
my %h1 = from-hjson $h1.IO.slurp;
isa-ok %h1, Hash;
for %h1<memo-line>.kv -> $k, $v {
    if $k.contains("length") {
        is $v, 0, "Hjson handles SOME trailing comments"; 
    }
}

# json register
my %j1 = from-json $j1.IO.slurp;
isa-ok %j1, Hash;
for %j1<check-numbers>.keys -> $k is copy {
    # keys are check numbers, convert to ints
    isa-ok $k, Str;
    $k .= Numeric;
    isa-ok $k, UInt, "IntStr to UInt";
}

done-testing;
