#!/usr/bin/env raku
use Test;

use YAMLish;
use File::Find;
use JSON::Hjson;
use JSON::Fast;

use Checkwriter::Vars;

# The 'check.hjson' file should have ALL known keys used by
#   the 'account.yml' file.
my $nfields = $NFIELDS;

my $y1 = "resources/account.yml";
my $y2 = "resources/config.yml";
my $h1 = "resources/check.hjson";
my $j1 = "resources/register.json";
my %h1 = from-hjson $h1.IO.slurp;

    # check out the check for 1 through $nfields
    my %id;
    for %h1.kv -> $k, $v {
        my $n = $v.^name;
        if $n eq 'Hash' {
            my %o = %h1{$k};
            my $id = 0;
            unless %o<id>:exists {
                note "WARNING: field $k has NO id key";
                next;
            }
            $id = %o<id>;
            if %id{$id}:exists {
                note "WARNING: field id $id is duplicated!";
            }
            else {
                %id{$id} = $k;
            }
        }
    }
    my $nid = %id.elems;
    is $nid, $nfields;

my %y1 = load-yaml $y1.IO.slurp;
for %y1.kv -> $k, $v {
    my $n = $v.^name;
    unless %h1{$k}:exists {
        # starting-transaction only used in account data
        next if $k.contains("starting-");
        # currency data only used in account data
        next if $k.contains("currency");
        note "WARNING: account key '$k' not in check hash":
    }
}

done-testing;


