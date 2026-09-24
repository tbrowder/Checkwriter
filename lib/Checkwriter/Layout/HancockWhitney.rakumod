unit module Checkwriter::Layout::HancockWhitney;

our constant %LAYOUT = %(
    'account-block'      => [36, 757],
    'account-line-space' => 13,
    'bank-name'          => [36, 614],
    'bank-address'       => [36, 692],
    'bank-address2'      => [36, 682],
    'check-number'       => [560, 757],
    'date-label'         => [465, 725],
    'date'               => [560, 725],
    'payee-label-1'      => [36, 669],
    'payee-label-2'      => [36, 659],
    'payee'              => [102, 660],
    'numeric-amount'     => [560, 660],
    'written-amount'     => [36, 629],
    'memo-label'         => [36, 589],
    'memo'               => [75, 589],
    'signature-label'    => [425, 574],
    'payee-line'         => [98, 656, 475, 656],
    'amount-line'        => [36, 624, 560, 624],
    'signature-line'     => [355, 585, 560, 585],
    'micr'               => [55, 561],
);

our sub hancock-whitney-layout(--> Hash) is export {
    %LAYOUT.Hash;
}
