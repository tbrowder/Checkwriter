unit module Checkwriter::Check;

use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;

use Checkwriter::MICR;

sub integer-to-words(
    Int $number,
    --> Str
) {
    my @ones = <
        zero one two three four five six seven eight nine
        ten eleven twelve thirteen fourteen fifteen sixteen
        seventeen eighteen nineteen
    >;

    my @tens = <
        zero zero twenty thirty forty fifty sixty seventy
        eighty ninety
    >;

    if $number < 20 {
        return @ones[$number];
    }

    if $number < 100 {
        my Int $tens = $number div 10;
        my Int $ones = $number mod 10;
        my Str $words = @tens[$tens];

        if $ones {
            $words ~= '-' ~ @ones[$ones];
        }

        return $words;
    }

    if $number < 1_000 {
        my Int $hundreds = $number div 100;
        my Int $remainder = $number mod 100;
        my Str $words = @ones[$hundreds] ~ ' hundred';

        if $remainder {
            $words ~= ' ' ~ integer-to-words($remainder);
        }

        return $words;
    }

    if $number < 1_000_000 {
        my Int $thousands = $number div 1_000;
        my Int $remainder = $number mod 1_000;
        my Str $words = integer-to-words($thousands) ~ ' thousand';

        if $remainder {
            $words ~= ' ' ~ integer-to-words($remainder);
        }

        return $words;
    }

    if $number < 1_000_000_000 {
        my Int $millions = $number div 1_000_000;
        my Int $remainder = $number mod 1_000_000;
        my Str $words = integer-to-words($millions) ~ ' million';

        if $remainder {
            $words ~= ' ' ~ integer-to-words($remainder);
        }

        return $words;
    }

    die 'Amount is too large for this version of Checkwriter';
}

our sub amount-to-words(
    Str $amount,
    --> Str
) is export {
    my Str $clean = $amount;
    $clean .= subst(',', '', :g);
    $clean .= subst('$', '', :g);
    $clean .= trim;

    die "Invalid amount '$amount'"
        unless $clean ~~ /^ \d+ [ '.' \d ** 1..2 ]? $/;

    my @parts = $clean.split('.');
    my Int $dollars = @parts[0].Int;
    my Str $cents = '00';

    if @parts.elems > 1 {
        $cents = @parts[1];

        if $cents.chars == 1 {
            $cents ~= '0';
        }
    }

    integer-to-words($dollars).uc ~ " AND $cents/100";
}

our sub formatted-amount(
    Str $amount,
    --> Str
) is export {
    my Str $clean = $amount;
    $clean .= subst(',', '', :g);
    $clean .= subst('$', '', :g);
    $clean .= trim;

    die "Invalid amount '$amount'"
        unless $clean ~~ /^ \d+ [ '.' \d ** 1..2 ]? $/;

    my @parts = $clean.split('.');
    my Str $dollars = @parts[0];
    my Str $cents = '00';

    if @parts.elems > 1 {
        $cents = @parts[1];

        if $cents.chars == 1 {
            $cents ~= '0';
        }
    }

    my Str $grouped = '';

    while $dollars.chars > 3 {
        my Str $group = $dollars.substr($dollars.chars - 3);
        $dollars = $dollars.substr(0, $dollars.chars - 3);
        $grouped = ',' ~ $group ~ $grouped;
    }

    '$' ~ $dollars ~ $grouped ~ '.' ~ $cents;
}

sub draw-line(
    $gfx,
    Numeric $x1,
    Numeric $y1,
    Numeric $x2,
    Numeric $y2,
) {
    $gfx.MoveTo($x1, $y1);
    $gfx.LineTo($x2, $y2);
    $gfx.Stroke;
}

sub masked-micr(
    Str:D $line,
    --> Str
) {
    my Str $masked = '';

    for $line.comb -> $glyph {
        given $glyph {
            when MICR-TRANSIT {
                $masked ~= 'T';
            }

            when MICR-ON-US {
                $masked ~= 'O';
            }

            when MICR-AMOUNT {
                $masked ~= 'A';
            }

            when MICR-DASH {
                $masked ~= 'D';
            }

            when /\d/ {
                $masked ~= '#';
            }

            default {
                $masked ~= $glyph;
            }
        }
    }

    $masked;
}

our sub create-check(
    %account,
    %layout,
    Str:D :$account-id!,
    Str:D :$output!,
    IO::Path:D :$micr-font-file!,
    Str:D :$date!,
    Str:D :$payee!,
    Str:D :$amount!,
    Str   :$memo = '',
    Bool  :$debug-micr = False,
    Str   :$micr-font-label = '',
    --> IO::Path
) is export {
    my Str $number = %account<next-check-number>.Str;
    my Str $amount-words = amount-to-words($amount);
    my Str $numeric-amount = formatted-amount($amount);

    my PDF::Content::FontObj $micr-font =
        load-font :file($micr-font-file.Str);

    my PDF::Lite $pdf .= new;
    $pdf.media-box = 'Letter';

    my PDF::Lite::Page $page = $pdf.add-page;
    my $body-font = $pdf.core-font(:family<Helvetica>);
    my $bold-font = $pdf.core-font(:family<Helvetica>, :weight<bold>);

    $page.text: -> $txt {
        my ($x, $y) = |%layout<account-block>;
        my Numeric $line-space = %layout<account-line-space>;

        $txt.font = $bold-font, 11;
        $txt.say(%account<name>, :position[$x, $y]);
        $y -= $line-space;

        if %account<name2>:exists
                and %account<name2>.Str.chars {
            $txt.say(%account<name2>, :position[$x, $y]);
            $y -= $line-space;
        }

        $txt.font = $body-font, 9;
        $txt.say(%account<address>, :position[$x, $y]);
        $y -= $line-space;

        if %account<address2>:exists
                and %account<address2>.Str.chars {
            $txt.say(%account<address2>, :position[$x, $y]);
            $y -= $line-space;
        }

        $txt.say(%account<city-state-zip>, :position[$x, $y]);

        $txt.font = $body-font, 9;
        $txt.say(%account<bank-name>, :position(%layout<bank-name>));

        $txt.font = $body-font, 8;
        $txt.say(%account<bank-address>, :position(%layout<bank-address>));

        if %account<bank-address2>:exists
                and %account<bank-address2>.Str.chars {
            $txt.say(
                %account<bank-address2>,
                :position(%layout<bank-address2>),
            );
        }

        $txt.font = $bold-font, 11;
        $txt.say(
            $number,
            :position(%layout<check-number>),
            :align<right>,
        );

        $txt.font = $body-font, 11;
        $txt.say('Date:', :position(%layout<date-label>));
        $txt.say(
            $date,
            :position(%layout<date>),
            :align<right>,
        );

        $txt.font = $body-font, 8;
        $txt.say('PAY TO THE', :position(%layout<payee-label-1>));
        $txt.say('ORDER OF', :position(%layout<payee-label-2>));

        $txt.font = $body-font, 11;
        $txt.say($payee, :position(%layout<payee>));

        $txt.font = $bold-font, 12;
        $txt.say(
            $numeric-amount,
            :position(%layout<numeric-amount>),
            :align<right>,
        );

        my Str $written-line =
            $amount-words ~ ' DOLLARS ' ~ ('*' x 18);

        $txt.font = $bold-font, 11;
        $txt.say($written-line, :position(%layout<written-amount>));

        $txt.font = $body-font, 8;
        $txt.say('MEMO', :position(%layout<memo-label>));

        if $memo.chars {
            $txt.font = $body-font, 9;
            $txt.say($memo, :position(%layout<memo>));
        }

        $txt.font = $body-font, 8;
        $txt.say(
            'AUTHORIZED SIGNATURE',
            :position(%layout<signature-label>),
        );
    };

    $page.graphics: -> $gfx {
        draw-line($gfx, |%layout<payee-line>);
        draw-line($gfx, |%layout<amount-line>);
        draw-line($gfx, |%layout<signature-line>);
    };

    my Str $line = micr-line(
        $account-id,
        %account<routing>.Str,
        %account<account>.Str,
        $number,
    );

    my ($micr-x, $micr-y) = |%layout<micr>;

    $page.text: -> $txt {
        $txt.font = $micr-font, MICR-FONT-SIZE;

        my Numeric $x = $micr-x;

        for $line.comb -> $glyph {
            if $glyph ne ' ' {
                $txt.say($glyph, :position[$x, $micr-y]);
            }

            $x += MICR-PITCH;
        }
    };

    if $debug-micr {
        constant DEBUG-X     = 36;
        constant DEBUG-Y     = 360;
        constant DEBUG-RIGHT = 468;

        my Int $glyph-count = $line.chars;
        my Numeric $chunk-width =
            $glyph-count * MICR-PITCH;

        my Str $pattern = masked-micr($line);

        $page.graphics: -> $gfx {
            draw-line(
                $gfx,
                DEBUG-X,
                DEBUG-Y,
                DEBUG-RIGHT,
                DEBUG-Y,
            );
        };

        my @debug-lines = (
            'MICR DEBUG INFORMATION',
            "Font:          $micr-font-label",
            "Font file:     {$micr-font-file.basename}",
            "Generated:     {DateTime.now}",
            "Font size:     {MICR-FONT-SIZE} pt",
            "Glyph pitch:   {MICR-PITCH} pt",
            "MICR X/Y:      $micr-x / $micr-y pt",
            "Glyph count:   $glyph-count",
            "Chunk width:   {$chunk-width.fmt('%.2f')} pt",
            "Chunk height:  {MICR-FONT-SIZE} pt (nominal)",
            "Pattern:       $pattern",
            "Account:       $account-id",
            "Check number:  $number",
        );

        $page.text: -> $txt {
            $txt.font = $body-font, 8;

            my Numeric $y = DEBUG-Y - 14;

            for @debug-lines -> $debug-line {
                $txt.say(
                    $debug-line,
                    :position[DEBUG-X, $y],
                );

                $y -= 11;
            }
        };
    }

    my IO::Path $output-file = $output.IO;
    $output-file.parent.mkdir unless $output-file.parent.e;
    $pdf.save-as($output-file.Str);

    $output-file = $output-file.IO;
}
