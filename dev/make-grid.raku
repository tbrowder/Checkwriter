#!/bin/env raku

use PDF::Lite;
use PDF::Font::Loader;
use PDF::Content::Color :ColorName, :&color;

#use lib <../lib>;
#use Calendar;
#use Calendar::Vars;
use Checkwriter::Utils;

# title of output pdf
my $ofile = "landscape-grid.pdf";

my $debug = 0;
if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a test PDF

    Options
        o[file]=X - Output file name [default: $ofile]
        a         - Use A4 paper

        d[ebug]   - Debug
    HERE
    exit
}

my $A4 = 0;
for @*ARGS {
    when /^ :i o[file]? '=' (\S+) / {
        $ofile = ~$0;
    }
    when /^ :i d / { ++$debug }
    when /^ :i a / { ++$A4    }
    when /^ :i g / {
        ; # go
    }
    default {
        note "WARNING: Unknown arg '$_'";
        note "         Exiting..."; exit;
    }
}

my ($PW, $PH); # paper width, height (portrait)
my ($LM, $TM, $RM, $BM); # margins (in final orientation)
$LM = 0.5  * 72;
$TM = 0.75 * 72;
if $A4 {
    $PW =  8.3  * 72;
    $PH = 11.7  * 72;
}
else {
    $PW =  8.5  * 72;
    $PH = 11.0  * 72;
}

# Do we need to specify 'media-box' on the whole document?
# No, it can be set per page.
my $pdf = PDF::Lite.new;
$pdf.media-box = $A4 ?? 'A4' !!'Letter';
my $font  = $pdf.core-font(:family<Times-RomanBold>);
my $font2 = $pdf.core-font(:family<Times-Roman>);

# write the desired pages
# ...
# start the document with the first page
make-page :$pdf, :$PW, :$PH, :$LM, :$font, :$font2;
make-page :$pdf, :$PW, :$PH, :$LM, :$font, :$font2;

my $pages = $pdf.Pages.page-count;
# save the whole thing with name as desired
$pdf.save-as: $ofile;
say "See outout pdf: $ofile";
say "Total pages: $pages";

#==== subroutines line
# all subs moved to Checkwriter/Utils.rakumod
