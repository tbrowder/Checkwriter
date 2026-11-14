#!/usr/bin/env raku

use Test;

use lib 'lib';

use Checkwriter::Check;
use Checkwriter::Config;
use Checkwriter::Layout;

constant ACCOUNT-ID   = 'hancock-whitney';
constant CHECK-NUMBER = '1290';
constant PAYEE        = 'Sam Palumbo';
constant AMOUNT       = '500.00';

my %account = load-account(ACCOUNT-ID);
my %layout  = layout-for(ACCOUNT-ID);

#
# Override only our in-memory copy.  The account JSON is not changed.
#
%account<next-check-number> = CHECK-NUMBER;

my IO::Path $public-font =
    $*PROGRAM.parent.parent
    .add('resources')
    .add('fonts')
    .add('Nimra-Regular.otf');

die "Public MICR font not found: $public-font"
    unless $public-font.f;

my IO::Path $private-font-dir =
    $*HOME.add('.checkwriter/fonts');

#die "Private MICR font not found: $private-font"
#    unless $private-font.f;

my Str $date = Date.today.Str;

my @samples = (
    {
        letter => 'A',
        name   => 'Nimra-Regular',
        font   => $public-font,
        output => 'micr-debug-nimra.pdf',
    },
    {
        letter => 'B',
        name   => 'MICRStd',
        font   => $private-font-dir.add('MICRStd.otf'),
        output => 'micr-debug-micrstd.pdf',
    },
    {
        letter => 'C',
        name   => 'GnuMICR-OTF',
        font   => $private-font-dir.add('GnuMICR.otf'),
        output => 'micr-debug-gnu-otf.pdf',
    },
    {
        letter => 'D',
        name   => 'GnuMICR-Type1-PFB',
        font   => $private-font-dir.add('GnuMICR.pfb'),
        output => 'micr-debug-gnu-type1.pdf',
    },
);

say();
say 'Generating MICR sample checks...';

for @samples -> %sample {
    my Str $letter = %sample<letter>;
    my Str $name   = %sample<name>;
    my IO::Path $font-file = %sample<font>;
    my Str $output = %sample<output>;

    say();
    say "Sample $letter: $name";

    unless $font-file.f {
        say "    FONT NOT FOUND: $font-file";
        next;
    }

    my Bool $success = True;

    try {
        create-check(
            %account,
            %layout,
            :account-id(ACCOUNT-ID),
            :$output,
            :micr-font-file($font-file),
            :$date,
            :payee(PAYEE),
            :amount(AMOUNT),
            :memo("Sample Check $letter"),
            :debug-micr,
            :micr-font-label($name),
        );

        CATCH {
            default {
                $success = False;
                say "    FAILED: $_";
            }
        }
    }

    if $success {
        say "    Created: $output";
    }
}

say();
say 'MICR sample generation finished.';

done-testing;
