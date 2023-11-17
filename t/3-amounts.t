use v6;
use Test;

plan 6;

use CheckWriter;

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

