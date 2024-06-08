#!/usr/bin/env raku

use YAMLish;
use File::Find;
use JSON::Hjson;
use JSON::Fast;
#use JSON::Class:auth<zef:vrurg>;
use JSON::Class:auth<zef:jonathanstowe>;

my $debug = 0;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [debug]
    HERE
    exit;
}

for @*ARGS {
    when /^ :i d/ {
        ++$debug;
    }
    default {
        ; # ok
    }
}

my $dir = "../resources";
my @yfils = find :$dir, :type<file>, :name(/:i '.' [yml|yaml] $/);
my @jfils = find :$dir, :type<file>, :name(/:i '.' [json] $/);
my @hfils = find :$dir, :type<file>, :name(/:i '.' [hjson] $/);

if $debug > 1 {
    say "../resources files:";
    say "  $_" for |@yfils, |@hfils, |@jfils;
}

my $y1 = "../resources/account.yml";
my $y2 = "../resources/config.yml";
my $h1 = "../resources/check.hjson";
my $j1 = "../resources/register.json";

# The 'check.hjson' file should have ALL known keys used by
#   the 'account.yml' file.
my $nfields = 22;
my %h1 = from-hjson $h1.IO.slurp;
if $debug {
    # check out the check for 1 through $nfields
    my %id;
    for %h1.kv -> $k, $v {
        my $n = $v.^name;
        say "Note: primary key '$k' has a value type of '$n'" if $debug > 1;
        if $n eq 'Hash' {
            my %o = %h1{$k};
            my $id = 0;
            unless %o<id>:exists {
                say "WARNING: field $k has NO id key";
                next;
            }
            $id = %o<id>;
            if %id{$id}:exists {
                say "WARNING: field id $id is duplicated!";
            }
            else {
                %id{$id} = $k;
            }
        }
    }
    my $nid = %id.elems;
    if $nid != $nfields {
        say "WARNING: Expected $nfields but got $nid";
    }
    my @id = %id.keys.sort({$^a <=> $^b});
    for @id {
        my $f = %id{$_};
        say "$f id: $_";
    }

}

my %y1 = load-yaml $y1.IO.slurp;
for %y1.kv -> $k, $v {
    my $n = $v.^name;
    say "Note: primary key '$k' has a value type of '$n'" if $debug > 1;
    unless %h1{$k}:exists {
        # starting-transaction only used in account data
        next if $k.contains("starting-");
        # currency data only used in account data
        next if $k.contains("currency");
        say "WARNING: account key '$k' not in check hash":
    }
}


# some MUST have keys from the same subset
# handlers subroutines MUST be defined for all key types
# handlers may be auto-generated

#==== subroutines line
# all subs moved to Checkwriter/Utils.rakumod


