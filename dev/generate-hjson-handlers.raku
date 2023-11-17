#!/bin/env raku
use JSON::Hjson;
use JSON::Fast;

my $debug = 0;

die "not used at the moment";

my $ifil = "data/Check.hjson";
my $ofil = "../lib/CheckWriter/Handlers.rakumod";

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [debug]
    
    Reads file '$ifil' and writes a 'handler'
    module that has handler subs for each entry.
    HERE
    exit
}

my $hash = from-hjson $ifil.IO.slurp;
my @keys = $hash.keys.sort;
if $debug {
    say " key $_" for @keys;
}

my $fh = open $ofil, :w;
$fh.print: qq:to/HERE/;
unit module CheckWriter::Handlers.rakumod;
HERE

for @keys -> $k {
    next if $k ~~ /^ base/;

    my %h = %($k);
    my @args = %h.keys.sort;
    $fh.print: qq:to/HERE/;

    sub {$k}-handler(:\$debug) is export \{
    }
    HERE
}
$fh.close;

say "Normal end.";
say "See output file: $ofil";
