use Test;

my @modules = [
   "Checkwriter",
   "Checkwriter::Handlers",
   "Checkwriter::Utils",
   "Checkwriter::PayTo",
   "Checkwriter::Action",
   "Checkwriter::Data",
   "Checkwriter::Vars",
   "Checkwriter::Template",
   "Checkwriter::SampleCheck",
   "Checkwriter::FontUtils",
];

plan @modules.elems;

for @modules -> $m {
    use-ok $m, "Module '$m' used okay";
}
