#!/usr/bin/env raku

use PDF::Lite;
use PDF::Font::Loader :load-font;

my IO::Path $font-file =
    "$*HOME/.checkwriter/fonts/GnuMICR.ttf".IO;

my Str $output = 'GnuMICR-specimen.pdf';

die "Font not found: $font-file"
    unless $font-file.f;

my $micr-font = load-font :file($font-file.Str);

my PDF::Lite $pdf .= new;
my PDF::Lite::Page $page = $pdf.add-page;

constant PITCH = 9;

sub draw-specimen(
    $page,
    $font,
    Str $sample,
    Numeric $x-start,
    Numeric $y,
    Numeric $size,
    --> Nil
) {
    $page.text: -> $txt {
        $txt.font = $font, $size;

        my Numeric $x = $x-start;

        for $sample.comb -> $glyph {
            if $glyph ne ' ' {
                $txt.say(
                    $glyph,
                    :position[$x, $y],
                );
            }

            $x += PITCH;
        }
    };

    return;
}

# MICR digits at two sizes.
draw-specimen(
    $page, $micr-font,
    '0123456789',
    72, 650, 10,
);

draw-specimen(
    $page, $micr-font,
    '0123456789',
    72, 600, 12,
);

# MICR special symbols, spaced for identification.
draw-specimen(
    $page, $micr-font,
    'A   B   C   D',
    72, 520, 10,
);

draw-specimen(
    $page, $micr-font,
    'A   B   C   D',
    72, 470, 12,
);

$pdf.save-as($output);

say "Created $output";
