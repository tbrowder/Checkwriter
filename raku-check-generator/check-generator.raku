use PDF::Lite;

# Convert a numeric amount (as Str) to check-style words
sub number-to-words($amount) {
    my @ones  = <zero one two three four five six seven eight nine>;
    my @teens = <ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen>;
    my @tens  = <zero ten twenty thirty forty fifty sixty seventy eighty ninety>;

    sub convert($n) {
        return @ones[$n] if $n < 10;
        return @teens[$n - 10] if $n < 20;
        return @tens[$n div 10] ~ (@ones[$n % 10] ne 'zero' ?? '-' ~ @ones[$n % 10] !! '') if $n < 100;
        return @ones[$n div 100] ~ ' hundred' ~ ($n % 100 ?? ' ' ~ convert($n % 100) !! '') if $n < 1000;
        return convert($n div 1000) ~ ' thousand' ~ ($n % 1000 ?? ' ' ~ convert($n % 1000) !! '') if $n < 1_000_000;
        return "amount-too-large";
    }

    my ($int, $frac) = $amount.split('.');
    $frac //= '00';
    $frac = $frac.substr(0, 2).pad(2, '0');

    my $words = convert($int.Int);
    "$words and $frac/100";
}

# Watermark helper: draw big text across the check area
sub add-watermark(
    $page,           # PDF::Lite::Page
    Numeric $page-width,
    Numeric $check-height,
    $font,           # regular font
    Str $text
) {
    my $x = $page-width / 4;
    my $y = $check-height / 2;

    $page.font($font, 60);
    $page.text(:x($x), :y($y), :text($text));
}

unit sub MAIN(
    Str :$date?,
    Bool :$today = False,
    Str :$payee?,
    Str :$amount?,
    Str :$memo?,
    Str :$signature?,
    Str :$routing?,
    Str :$account?,
    Str :$check-num?,
    Str :$watermark?,           # optional custom watermark text
    Bool :$void-watermark = False,  # use 'VOID' watermark
    Bool :$preview = False,
    Bool :$print = False,
    Bool :$list-printers = False,
    Str :$printer?,
    Bool :$help = False
) {
    if $help {
        say q:to/HERE/;
Usage: raku check-generator.raku [options]
Options:
  --today               Use today's date
  --date=YYYY-MM-DD     Use specific date
  --payee=NAME          Payee name
  --amount=AMT          Amount in dollars
  --memo=TEXT           Memo field
  --signature=TEXT      Signature line
  --routing=NUM         Bank routing number
  --account=NUM         Account number
  --check-num=NUM       Check number
  --preview             Open the PDF for preview (adds SAMPLE watermark by default)
  --watermark=TEXT      Custom watermark text (used with --preview or --void-watermark)
  --void-watermark      Use 'VOID' watermark text
  --print               Send to printer
  --printer=NAME        Specify printer name (Linux/macOS, CUPS)
  --list-printers       Show available printers
  --help                Show this help
HERE
        exit;
    }

    if $list-printers {
        my $os = $*DISTRO.name;
        say "🖨️ Available printers:";
        my $cmd = do given $os {
            when /Windows/ { 'wmic printer get name' }
            when /Darwin/  { 'lpstat -p | awk \'{print $2}\'' }
            when /Linux/   { 'lpstat -e' }
            default        { 'echo "Unsupported OS for listing printers."' }
        };
        shell($cmd);
        exit;
    }

    sub prompt($label, $default?) {
        if $default.defined {
            print "$label [$default]: ";
        }
        else {
            print "$label: ";
        }
        my $input = $*IN.get // '';
        $input = $input.trim;
        return $input || ($default // '');
    }

    my %check;
    my $today-str = Date.today.Str;

    %check<date>        = $date // ($today ?? $today-str !! prompt("Date", $today-str));
    %check<payee>       = $payee // prompt("Payee");
    %check<amount>      = $amount // prompt("Amount (e.g. 1234.56)");
    %check<memo>        = $memo // prompt("Memo");
    %check<signature>   = $signature // prompt("Signature line text");
    %check<routing>     = $routing // prompt("Routing number");
    %check<account>     = $account // prompt("Account number");
    %check<check-num>   = $check-num // prompt("Check number");
    %check<amount-text> = number-to-words(%check<amount>);

    # Decide watermark text, if any
    my $wm-text = "";
    if $void-watermark {
        $wm-text = "VOID";
    }
    elsif $watermark.defined {
        $wm-text = $watermark;
    }
    elsif $preview {
        $wm-text = "SAMPLE";
    }

    generate-check(%check, :$preview, :$print, :$printer, :$wm-text);
}

sub generate-check(
    %check,
    Bool :$preview = False,
    Bool :$print = False,
    Str  :$printer?,
    Str  :$wm-text = ""
) {
    my $page-width  = 8.5 * 72;
    my $page-height = 11  * 72;
    my $check-height = $page-height / 3;
    my $margin = 36;

    my $pdf = PDF::Lite.new;
    $pdf.add-page(:$page-width, :$page-height);
    my $page = $pdf.page(0);

    my $font-regular = $pdf.load-font("Helvetica");
    my $font-micr    = $pdf.load-font("MICR.ttf");

    # Logo image (replace logo.png with your real logo file)
    $page.image("logo.png", :x($margin + 10), :y($page-height - $check-height + $margin + 20), :width(100));

    # Check border (bottom third of the page)
    $page.rect($margin, $margin, $page-width - 2 * $margin, $check-height - 2 * $margin);
    $page.stroke;

    # Optional watermark
    if $wm-text ne "" {
        add-watermark($page, $page-width, $check-height, $font-regular, $wm-text);
    }

    sub draw-text($text, :$x, :$y, :$size = 10, :$font = $font-regular) {
        $page.font($font, $size);
        $page.text(:$x, :$y, :$text);
    }

    my $base-y = $margin;
    my $line1 = $base-y + $check-height - 60;
    my $line2 = $line1 - 40;
    my $line3 = $line2 - 40;
    my $line4 = $base-y + 50;
    my $micr-y = $base-y + 20;

    draw-text("Date:        " ~ %check<date>,            :x($margin + 400), :y($line1));
    draw-text("Pay to the Order of:   " ~ %check<payee>,  :x($margin + 20),  :y($line2));
    draw-text("\$" ~ %check<amount>,                      :x($margin + 400), :y($line2));
    draw-text(%check<amount-text>,                        :x($margin + 20),  :y($line3));
    draw-text("Memo: " ~ %check<memo>,                    :x($margin + 20),  :y($line4));
    draw-text("Signature: ______________________",        :x($margin + 300), :y($line4));

    # MICR line using the MICR font
    my $micr-line = "C" ~ %check<routing> ~ "C A" ~ %check<account> ~ "A" ~ %check<check-num> ~ "B";
    draw-text($micr-line, :x($margin + 20), :y($micr-y), :size(12), :font($font-micr));

    my $file = "bank-check.pdf";
    $pdf.save-as($file);
    say "✔ Check saved to $file";

    if $preview {
        my $os = $*DISTRO.name;
        my $cmd = do given $os {
            when /Windows/ { "start "$file"" }
            when /Darwin/  { "open "$file"" }
            when /Linux/   { "xdg-open "$file"" }
            default        { "echo 'Preview not supported on $os'" }
        };
        shell($cmd);
    }

    if $print {
        my $os = $*DISTRO.name;
        my $cmd = do given $os {
            when /Windows/ { "start /min acrord32 /p /h "$file"" }
            when /Darwin/  { $printer ?? "lp -d "$printer" "$file"" !! "lp "$file"" }
            when /Linux/   { $printer ?? "lp -d "$printer" "$file"" !! "lp "$file"" }
            default        { "echo 'Printing not supported on $os'" }
        };
        say "🖨️ Sending to printer...";
        shell($cmd);
    }
}
