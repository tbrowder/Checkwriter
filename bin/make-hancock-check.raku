#!/usr/bin/env raku
use JSON::Fast;
use Checkwriter::SampleCheck :render-check, :load-layout;

my %layout = load-layout("config/banks/check-layout-hancock.json");
render-check(
    :outfile("output/hancock-sample.pdf"),
    :layout(%layout),
    :%data(
        addr1 => "JOHN G. AND SALLY D. JOHNSON",
        addr2 => "123 MAIN STREET",
        addr3 => "ANYTOWN, USA 99999",
        check_number => "2042",
        date => "08/19/2025",
        payee => "Water Works",
        amount_num => "$ 88.20",
        amount_words => "Eighty-eight and 20/100",
        memo => "Acct 778899",
        bank_info => "HANCOCK WHITNEY BANK",
        micr_routing => "000000000",
        micr_account => "000000000000",
        micr_checkno => "2042"
    ),
);
say "Wrote output/hancock-sample.pdf";
