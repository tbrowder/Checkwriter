#!/usr/bin/env raku

use PDF::API6;
use PDF::Page;
use PDF::Content::Page :PageSizes;
use PDF::Content::Font::CoreFont;
constant CoreFont = PDF::Content::Font::CoreFont;

use Text::Utils :commify;

my $ifil = "form-8949-blank.pdf";
my $debug = 0;
my @ofils;

my @datalines = [
# each line has 5 fields of text and numbers
# num shares and description | date acquired | date sold     | sales price | cost
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
(100, "sh", "Foo Industries, Inc.",                 "10/11/2010",   "01/03/2019",   "2000",    "1500"),
(100, "sh", "Foo Industries, Inc.",                 "10/14/2010",   "01/03/2019",   "2000",    "1500"),
(50.234, "sh",  "Loser, Inc.",     "06/05/2009",   "01/03/2019",   "1102500", "1700000"),
(100.0, "sh",  "Fairy Dust, Inc.",   "06/05/2001",   "01/03/2019",   "20500",   "18500"),
(66.0, "sh",  "Fairy Dust (Preferred), Inc.",   "06/05/2001",   "01/03/2019",   "2220500",   "18500"),
];

#my @data = @datalines.shift.flat;
#dd @data;
#exit;

for 1..1 -> $n {
    my $ofil = "form-8949-page-$n.pdf";
    @ofils.push: $ofil;

    my $pdf = PDF::API6.new;
    # Open an existing PDF file
    $pdf .= open($ifil);
    # Retrieve an existing page
    my $page = $pdf.page(1);

    # Set the default page size for all pages
    $pdf.media-box = Letter;
    # Use a standard PDF core font
    my $font = $pdf.core-font: :family<Courier>; #, :weight<Bold>;
    # Add some text to the page

    # one line of form data
    my $y = 660; # starting y distance for the first line
    my $text-dy = 3.0; # distance of text baseline above each line

    # there are 35 data lines in all spanning 627.5 points
    my $dy = 627.5 / 35; # distance between lines

    # 35 lines on a page
    for 1..35 -> $n {
        $y -= $dy if $n > 1;
        my $ty = $y +  $text-dy;

        # add lines for all

        # add the text lines until consumed
        if @datalines.elems {
            my @data = @datalines.shift.flat;
            # the first field id the number of shares: nnn.nnn
            my $nsh = @data.shift;
            $nsh = sprintf '%7.3f', $nsh;
            # remove decimals if all zeroes
            $nsh ~~ s/'.000'$/    /;

            my $sh = @data.shift;

            # the last two fields are whole dollars and need to be
            # sprintf'd to look nice (add commas but no dollar symbol)
            my $cost = @data.pop;
            note "DEBUG: cost             = '$cost'" if $debug;
            $cost = commify $cost;
            note "DEBUG: commified cost   = '$cost'" if $debug;
            $cost = sprintf '%9.9s', $cost;
            note "DEBUG: \$ commified cost = '$cost'" if $debug;

            my $saleprice = @data.pop;
            $saleprice = commify $saleprice;
            $saleprice = sprintf '%9.9s', $saleprice;

            $page.text: {
                .font = $font, 9;
                # field 0
                # description of property (include number of shares)
                .text-position = 38, $ty;
                .print("$nsh");
                .text-position = 80, $ty;
                .print("$sh");
                .text-position = 97, $ty;
                .print("{@data[0]}");

                # field 1
                # date acquired
                .text-position = 315, $ty;
                .print("{@data[1]}");

                # field 2
                # date sold
                .text-position = 378, $ty;
                .print("{@data[2]}");

                # field 3
                # sale price
                .text-position = 499, $ty;
                .print("$saleprice", :align<right>);

                # field 4
                # cost
                .text-position = 563, $ty;
                .print("$cost", :align<right>);
            }
        }

        # add the lines
        $page.graphics: {
            # five separate lines with minimum linewidth
            .LineWidth = 0.2; # set stroking line-width

            # field 0
            .MoveTo( 37.5, $y); .LineTo(303.5, $y); .Stroke;
            # field 1
            .MoveTo(313.0, $y); .LineTo(372.0, $y); .Stroke;
            # field 2
            .MoveTo(375.5, $y); .LineTo(434.5, $y); .Stroke;
            # field 3
            .MoveTo(444.5, $y); .LineTo(503.5, $y); .Stroke;
            # field 4
            .MoveTo(507.5, $y); .LineTo(566.5, $y); .Stroke;
        }
    }


    # Save the new PDF
    $pdf.save-as: $ofil;
}

say "Normal end.";
if @ofils.elems {
    say "Files generated:";
    say "  $_" for @ofils;
}
else {
    say "No files were generated:";
}
