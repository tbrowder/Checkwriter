unit module Checkwriter::Resources;

sub get-meta-hash(:$debug --> Hash) is export {
   $?DISTRIBUTION.meta
}

sub get-resources-paths(:$debug --> List) is export {
    my @list =
        $?DISTRIBUTION.meta<resources>.map({"resources/$_"});
    @list
}

sub get-resources-hash(:$debug --> Hash) is export {
    my @list =
        $?DISTRIBUTION.meta<resources>.map({"resources/$_"});
    my %h;
    for @list {
        my $f = $_.IO.basename;
        if %h{$f}:exists {
            %h{$f}.push: $_;
        }
        else {
            %h{$f} = [];
            %h{$f}.push: $_;
        }
    }
    %h
}

sub get-content($path, :$nlines = 0) is export {
    my $exists = resource-exists $path;
    unless $exists { return 0; }

    my $s = $?DISTRIBUTION.content($path).open.slurp;
    if $nlines {
        my @lines = $s.lines;
        my $nl = @lines.elems;
        if $nl >= $nlines {
            $s.lines[0..$nlines-1].join("\n");
        }
        else {
            $s;
        }
    }
    else {
        $s
    }
} # sub get-content($path, :$nlines = 0) is export {

sub resource-exists($path? --> Bool) is export {
    return False if not $path.defined;

    # "eats" both warnings and errors; fix coming to Zef
    # as of 2023-10-29
    # current working code courtesy of @ugexe
    try {
        so quietly $?DISTRIBUTION.content($path).open(:r).close; # may die
    } // False;
}
