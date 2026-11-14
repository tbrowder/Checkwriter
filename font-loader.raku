#!/usr/bin/env raku

use PDF::Font::Loader :load-font;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Checks loading of a set of fonts.

    HERE
    exit;
}

say "Checking loading of fonts...";
# get an IPO::Path object...
my $fdir = $*HOME.add(".checkwriter/fonts");
my @font-files = (
    #"GnuMICR.afm",
    "GnuMICR.otf",
    #"GnuMICR.pfa",
    "MICRStd.otf",
);

for @font-files -> $font-file {
    my $ffile = "$fdir/$font-file".IO;
    say "Attempting to load font '$ffile'...";
    my $font = load-font :file($ffile);

    say '  Font.^name (class name): ', $font.^name;
    say '  Font.font-name: ', $font.font-name;
    say '  Font.family: ', $font.family;
    say '  Font.file: ', $font.file;
    say '  Font.height: ', $font.height;
}
