#!/usr/bin/env raku

use lib 'lib';

use Checkwriter::Check;
use Checkwriter::Config;
use Checkwriter::Layout;

constant ACCOUNT-ID   = 'hancock-whitney';
constant CHECK-NUMBER = '1290';
constant PAYEE        = 'Sam Palumbo';
constant AMOUNT       = '500.00';
constant MEMO         = 'test sample';

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

my IO::Path $private-font = private-micr-font();

die "Private MICR font not found: $private-font"
    unless $private-font.f;

my Str $date = Date.today.Str;

my IO::Path $public-output =
    'micr-debug-public.pdf'.IO;

my IO::Path $private-output =
    'micr-debug-private.pdf'.IO;

create-check(
    %account,
    %layout,
    :account-id(ACCOUNT-ID),
    :output($public-output.Str),
    :micr-font-file($public-font),
    :$date,
    :payee(PAYEE),
    :amount(AMOUNT),
    :memo(MEMO),
    :debug-micr,
    :micr-font-label<Nimra-Regular>,
);

create-check(
    %account,
    %layout,
    :account-id(ACCOUNT-ID),
    :output($private-output.Str),
    :micr-font-file($private-font),
    :$date,
    :payee(PAYEE),
    :amount(AMOUNT),
    :memo(MEMO),
    :debug-micr,
    :micr-font-label<MICR-Std-Medium>,
);

say();
say 'MICR debug checks generated:';
say "    $public-output";
say "    $private-output";
