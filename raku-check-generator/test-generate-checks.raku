#!/usr/bin/env raku
# Generate a few sample checks for visual/layout testing.

my @samples;
@samples.push: {
    payee     => "Sample Payee One",
    amount    => "123.45",
    memo      => "Test check 1",
    check-num => "1001",
};
@samples.push: {
    payee     => "Sample Payee Two",
    amount    => "678.90",
    memo      => "Test check 2",
    check-num => "1002",
};
@samples.push: {
    payee     => "Long Name Payee Incorporated",
    amount    => "1500.00",
    memo      => "Test check 3 with longer memo",
    check-num => "1003",
};

my $idx = 0;
for @samples -> %s {
    $idx++;
    my $cmd = "raku check-generator.raku --today"
        ~ " --payee="" ~ %s<payee> ~ """
        ~ " --amount=" ~ %s<amount>
        ~ " --memo="" ~ %s<memo> ~ """
        ~ " --signature="Test Signer""
        ~ " --routing=123456789"
        ~ " --account=000123456789"
        ~ " --check-num=" ~ %s<check-num>
        ~ " --watermark=SAMPLE";

    say "Running: $cmd";
    shell $cmd;

    my $target = "sample-check-$idx.pdf";
    my $mv-cmd = "mv bank-check.pdf "$target"";
    say "Renaming bank-check.pdf -> $target";
    shell $mv-cmd;
}

say "Done. Generated sample-check-1.pdf, sample-check-2.pdf, sample-check-3.pdf";
