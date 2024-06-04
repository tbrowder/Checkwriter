use v6;
use Test;

use JSON::Hjson;
use JSON::Fast;
use YAMLish;

my $y1 = "t/data/config.yml";
my $y2 = "t/data/user-account-data.yml";
my $h1 = "t/data/user-check-data.hjson";
my $j1 = "t/data/register.json";

# yaml files
my %y1 = load-yaml $y1.IO.slurp;
isa-ok %y1, Hash;
my %y2 = load-yaml $y2.IO.slurp;
isa-ok %y2, Hash;

# hjson
my %h1 = from-hjson $h1.IO.slurp;
isa-ok %h1, Hash;

# json
my %j1 = from-json $j1.IO.slurp;
isa-ok %j1, Hash;

done-testing;

=finish

use Checkwriter;

my $amt;

$amt = amount2words "2.46";
is $amt, "two and 46/100".uc;

$amt = amount2words "2";
is $amt, "two and no/100".uc;

$amt = amount2words "2.";
is $amt, "two and no/100".uc;

$amt = amount2words "2.03";
is $amt, "two and 3/100".uc;

$amt = amount2words "2.3";
is $amt, "two and 30/100".uc;

dies-ok {
    $amt = amount2words "2.300";
}

