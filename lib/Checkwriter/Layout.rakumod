unit module Checkwriter::Layout;

use Checkwriter::Layout::HancockWhitney;
use Checkwriter::Layout::Fidelity;
use Checkwriter::Layout::CharlesSchwab;

our sub layout-for(
    Str $account-id,
    --> Hash
) is export {
    given $account-id {
        when 'hancock-whitney' {
            return hancock-whitney-layout();
        }

        when 'fidelity' {
            return fidelity-layout();
        }

        when 'charles-schwab' {
            return charles-schwab-layout();
        }

        default {
            die "No layout defined for '$account-id'";
        }
    }
}
