#!/usr/bin/env raku
use JSON::Fast;
use Checkwriter::SampleCheck :render-check, :load-layout;

my %layout = load-layout("config/banks/check-layout-fidelity.json");
render-check(
    :outfile("output/fidelity-sample.pdf"),
    :layout(%layout),
    :%data(
        addr1 => "JOHN G. AND SALLY D. JOHNSON",
        addr2 => "123 MAIN STREET",
        addr3 => "ANYTOWN, USA 99999",
        check_number => "1035",
        date => "08/19/2025",
        payee => "Phone Company",
        amount_num => "$ 67.89",
        amount_words => "Sixty-seven and 89/100",
        memo => "Acct 12345",
        bank_info => "UMB BANK N.A., KANSAS CITY, MO",
        micr_routing => "000000000",
        micr_account => "000000000000",
        micr_checkno => "1035"
    ),
);
say "Wrote output/fidelity-sample.pdf";
