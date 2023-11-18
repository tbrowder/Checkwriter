#!/usr/bin/env raku

use JSON::Hjson;
use JSON::Fast;
use JSON::Class;
use File::Find;

use lib <../lib>;
use CheckWriter;

my $chk  = "../resources/quicken.chk";
my $rdir = "../resources";

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | inspect [debug]

    Inspects and uses GnuCash *.chk and other data in
    directory:

      $rdir

    Goal is to print the selected one as is for
    a start of my own check.

    HERE
    exit;
}

my $insp  = 0;
my $debug = 0;
for @*ARGS {
    when /^:i i/ { ++$insp }
    when /^:i d/ { ++$debug }
    default {
      note "WARNING: Unhandled arg '$_'";
    }
}

my @fils  = find :dir($rdir), :type<file>;
unless $insp {
    say "Data files:";
    say "  $_" for @fils;
    exit;
}

say "Inspecting chk file '$chk'";
if $debug {
    say "  (use for a start):";
    say();
    say "  $_" for $chk.IO.lines;
}

my (@fields, @lines);

=begin comment
  // PS points from lower left of check paper to lower-left of the check
  base-origin: 0 546
  base-font: t10
  base-stroke: 0
  // PS points from lower-left of base-origin to top-left corner of the check
  top-origin: 0 244
  // named fields with origin (llx, lly from base-origin), other fields
  // as appropriate:
=end comment

my $base-origin-x = 0;
my $base-origin-y = 546;
my $page-width    = 612;
my $page-height   = 792;


my $height = 792 - 546;
my $translation;
my $rotation;

my %grps;

for $chk.IO.lines {
    next if $_ !~~ /\S/;
    next if $_ ~~ /^ :i \h* '[' \h* block|check|top|show|guid|title /;

    # take only lines of interest
    when /:i translation \h* '=' (\N+) $/ {
        say "handled1: '$_'" if $debug;
        my $val = ~$0;
        $translation = $val;
    }
    when /:i rotation \h* '=' (\N+) $/ {
        say "handled2: '$_'" if $debug;
        my $val = ~$0;
        $rotation = $val;
    }
    when /:i height \h* '=' (\N+) $/ {
        # don't use this valuu, use mine
        say "handled3: '$_'" if $debug;
    }
    when /^:i \h* (\S+) \h* '=' (\N+) $/ {
        my $t = ~$0;
        my $val  = ~$1;

        my $g = False;
        my ($typ, $grp);
        if $t ~~ /:i (<[a..z]>+) '_' (\d+) / {
            say "handled4t: '$_'" if $debug;
            $typ = ~$0;
            $grp = ~$1;
        }
        if $grp.defined and $typ.defined {
            if %grps{$grp}{$typ}:exists {
                say "WARNING: Duplicate group/type $grp/$typ"; 
            }
            %grps{$grp}{$typ} = $val;
        }
    }
    default {
        say "** unhandled **: '$_'" if $debug;
    }
}


say "Results: ";
say "  Check height     : $height";
say "        translation: $translation";
say "        rotation   : $rotation";
sub get-coords($v is copy --> List) is export {
    # valid inputs:
    #   x;y
    #   x1;y1;x2;y2
    # return a list of values
    my ($x1, $y1, $x2, $y2);
    $v ~~ s:g/';'/ /;
    $v.words;
}

for %grps.keys.sort -> $g {
    say "  Group $g";
    my %h = %(%grps{$g});
    my ($field, $line) = (False, False);
    for %h.kv -> $k, $v {
        next if $k ~~ /:i chars /;
        #say "    type: $k ; value: $v";
        if $k ~~ /:i coords / {
            my $c = $v;
            $c ~~ s:g/';'/ /;
            my @c = $c.words;
            say "      coordinates: {@c.raku}";
            #say "      coordinates: $v";
        }
        elsif $k ~~ /:i type / {
            say "      field name: $v";
        }
        else {
            say "      unhandled type '$k'";
        }
    }
    my $o;
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



