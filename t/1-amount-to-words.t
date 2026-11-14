use v6.d;
use Test;
use Checkwriter::Check;

plan 6;

my %cases = (
    '10'    => 'TEN and NO/100',
    '10.00' => 'TEN and NO/100',
    '10.03' => 'TEN and 3/100',
    '10.3'  => 'TEN and 30/100',
    '10.30' => 'TEN and 30/100',
    '10.99' => 'TEN and 99/100',
);

for %cases.keys.sort -> $amount {
    is amount-to-words($amount),
       %cases{$amount},
       "Amount $amount formatted correctly";
}
