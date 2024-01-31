use v6;
use Test;
use Proc::Easier;

use Checkwriter;
use Checkwriter::Data;

my ($cmd, $args);

lives-ok {
    list-resources;
}

for @resources-list -> $subpath {
    my $path = "resources/$subpath";
    is resource-exists($path), True
}

done-testing;
