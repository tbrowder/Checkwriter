#!/usr/bin/env raku

use JSON::Hjson;
use JSON::Fast;
use JSON::Class;
use File::Find;

use lib <../lib>;
use Checkwriter;

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
    when /^:i g/ { 
        ; # ok: go
    }
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

# my check paper values
my $base-origin-x = 0;
my $base-origin-y = 546;
my $page-width    = 612;
my $page-height   = 792;
my $chk-height = 792 - 546;

# chk file inputs 
my $translation;
my $translation-x;
my $translation-y;
my $rotation;

my %grps;

for $chk.IO.lines {
    next if $_ !~~ /\S/;
    next if $_ ~~ /^ :i \h* '[' \h* block|check|top|show|guid|title /;

    # take only lines of interest
    when /:i translation \h* '=' (\N+) $/ {
        say "handled1: '$_'" if $debug;
        my $val = ~$0;
        $val ~~ s:g/';'/ /;
        my @c = $val.words;
        $val = @c.join(' ');
        $translation = $val;
        $translation-x = @c.head;
        $translation-y = @c.tail;
    }
    when /:i rotation \h* '=' (\N+) $/ {
        say "handled2: '$_'" if $debug;
        my $val   = ~$0;
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

=begin comment
my $base-origin-x = 0;
my $base-origin-y = 546;
my $page-width    = 612;
my $page-height   = 792;
=end comment


say "Results: ";
say "  Page base coords:";
say "     base-origin-x: $base-origin-x";
say "     base-origin-y: $base-origin-y";
say "     page-width   : $page-width";
say "     page-height  : $page-height";
say "  Check height    : $chk-height";
say "     translation-x: $translation-x";
say "     translation-y: $translation-y";
say "     rotation     : {$rotation.= trim}";

my $csv = "check-dimens.csv";
my $fh = open $csv, :w;
# write header row
$fh.say: "id, type, label, descrip, x1, y1, x2, y2"; 

for %grps.keys.sort -> $g {
    say "  Group $g";
    my %h = %(%grps{$g});
    my ($field, $line) = (False, False);

    # prepare a data line in pieces
    my $id = "$g";

    my $type    = "";
    my $label   = "";
    my $descrip = "";
    my $coords  = ""; # 4 columns

    my $dataline = "$id, $type, $label, $descrip, $coords";
    for %h.kv -> $k, $v {
        next if $k ~~ /:i chars /;
        #say "    type: $k ; value: $v";
        if $k ~~ /:i coords / {
            my $c = $v;
            $c ~~ s:g/';'/ /;
            my @c = $c.words;
            $c = @c.join(' ');
            if @c.elems == 4 {
                $coords = @c.join(',');
                say "      coord x1 = ", @c[0];
                say "            y1 = ", @c[1];
                say "            x2 = ", @c[2];
                say "            y2 = ", @c[3];
                $type    = "line";
                #$descrip = $k;
            }
            elsif @c.elems == 2 {
                say "      coord x1 = ", @c[0];
                say "            y1 = ", @c[1];
                $coords = @c[0..1].join(',');
                $coords ~= ',,';
                $type    = "field";
                #$descrip = $k;
            }
            else {
                say "      coordinates: $c";
                $coords = @c.head;
                $coords ~= ',,,';
            }
        }
        elsif $k ~~ /:i type / {
            say "      field name: $v";
            $label = $v;
        }
        else {
            say "      unhandled type '$k'";
        }
    } # end of a group

    # update the data line
    $dataline = "$id, $type, $label, $descrip, $coords";
    $fh.say: $dataline;
} # end of group list

$fh.close;
say "See output CSV file: $csv";

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


