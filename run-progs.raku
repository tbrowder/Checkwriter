#!/usr/bin/env raku

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} cw | cp | cs

    cw - checkwriter
    cp - cw-pay
    cs - cw-setup

    HERE
    exit;
}

for @*ARGS {
    when /^ :i cw/ {
        shell "raku -I. bin/checkwriter";
    }
    when /^ :i cp/ {
        shell "raku -I. bin/cw-pay";
    }
    when /^ :i cs/ {
        shell "raku -I. bin/cw-setup";
    }
}
