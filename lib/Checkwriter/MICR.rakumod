unit module Checkwriter::MICR;

our constant MICR-TRANSIT is export = chr(0x2446);
our constant MICR-ON-US   is export = chr(0x2447);
our constant MICR-AMOUNT  is export = chr(0x2448);
our constant MICR-DASH    is export = chr(0x2449);

our constant MICR-FONT-SIZE is export = 10;
our constant MICR-PITCH     is export = 9;

our sub micr-line(
    Str $account-id,
    Str $routing,
    Str $account,
    Str $number,
    --> Str
) is export {
    given $account-id {
        when 'hancock-whitney' {
            return MICR-TRANSIT
                ~ $routing
                ~ MICR-TRANSIT
                ~ '  '
                ~ $account
                ~ MICR-ON-US
                ~ '   '
                ~ $number;
        }

        when 'fidelity' {
            return MICR-TRANSIT
                ~ $routing
                ~ MICR-TRANSIT
                ~ $number
                ~ MICR-ON-US
                ~ $account
                ~ MICR-ON-US;
        }

        when 'charles-schwab' {
            return MICR-TRANSIT
                ~ $routing
                ~ MICR-TRANSIT
                ~ '  '
                ~ $account
                ~ MICR-ON-US
                ~ '    '
                ~ $number;
        }

        default {
            die "No MICR format defined for '$account-id'";
        }
    }
}
