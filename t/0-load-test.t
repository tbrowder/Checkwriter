use Test;

my @modules = [
    "Checkwriter",
    "Checkwriter::Layout",
    "Checkwriter::MICR",
    "Checkwriter::Layout",
    "Checkwriter::Layout::Fidelity",
    "Checkwriter::Layout::CharlesSchwab",
    "Checkwriter::Layout::HancockWhitney",
    "Checkwriter::Check",
    "Checkwriter::Config",
];

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
