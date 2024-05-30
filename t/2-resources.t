use Test;

use Checkwriter;
use Checkwriter::Resources;

my (@res, $cmd, $args);

lives-ok {
    @res = get-resources-paths;
}

done-testing;
