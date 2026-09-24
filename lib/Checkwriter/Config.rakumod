unit module Checkwriter::Config;

use JSON::Fast;

our sub canonical-account-id(
    Str $id is copy,
    --> Str
) is export {
    $id .= lc;

    given $id {
        when 'h' | 'hancock-whitney' {
            return 'hancock-whitney';
        }

        when 'f' | 'fidelity' {
            return 'fidelity';
        }

        when 's' | 'c' | 'charles-schwab' {
            return 'charles-schwab';
        }

        default {
            die "Unknown account '$id'";
        }
    }
}

our sub private-root(--> IO::Path) is export {
    if %*ENV<CHECKWRITER_PRIVATE>:exists
            and %*ENV<CHECKWRITER_PRIVATE>.chars {
        return %*ENV<CHECKWRITER_PRIVATE>.IO;
    }

    $*HOME.add('.checkwriter');
}

our sub account-dir(
    Str $account-id,
    --> IO::Path
) is export {
    private-root().add('accounts').add($account-id);
}

our sub load-account(
    Str $account-id,
    --> Hash
) is export {
    my IO::Path $file =
        account-dir($account-id).add('account.json');

    die "Missing account file '$file'"
        unless $file.f;

    from-json($file.slurp).Hash;
}

our sub private-micr-font(--> IO::Path) is export {
    private-root().add('fonts').add('MICRStd.otf');
}
