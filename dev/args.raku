#!/usr/bin/env raku

for @*ARGS {
    when .starts-with(<s>) {
        say "expected arg starts with: $_"
    }
    default {
        say "unhandled arg is: $_"
    }
}

