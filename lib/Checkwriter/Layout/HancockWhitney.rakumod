unit module Checkwriter::Layout::HancockWhitney;

our constant %LAYOUT = %(
    'account-block'      => [36, 766],
    'account-line-space' => 13,
    'bank-name'          => [36, 629],
    'bank-address'       => [36, 692],
    'bank-address2'      => [36, 682],
    'check-number'       => [560, 766],
    'date-label'         => [465, 734],
    'date'               => [560, 734],

    'payee-label-1'      => [36, 687],
    'payee-label-2'      => [36, 677],
    'payee'              => [102, 678],
    'numeric-amount'     => [560, 678],
    'written-amount'     => [36, 647],
    'memo-label'         => [36, 607],
    'memo'               => [75, 607],
    'signature-label'    => [425, 592],
    'payee-line'         => [98, 674, 475, 674],
    'amount-line'        => [36, 642, 560, 642],
    'signature-line'     => [355, 603, 560, 603],

    'micr'               => [55, 561],
);

our sub hancock-whitney-layout(--> Hash) is export {
    %LAYOUT.Hash;
}
