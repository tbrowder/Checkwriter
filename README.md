[![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions) [![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions) [![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/windows-spec.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions)

Checkwriter
===========

Using Hjson templates similar to the format of the check (*.chk) files of [GnuCash](https://gnucash.org), this module and its binary programs allows the user to print checks on standard sizes of paper.

The default is to print a single check on Office Depot's single-check paper (US Letter size) using the provided check template file. The font used is the **E-13B, Common Machine Language font** in a free (for non-commercial use) implementation called the *MICR Encoding Font* provided by **[1001 Fonts](https://www.1001fonts.com/micr-encoding-font.html#styles)** with reasonable [terms of use](https://www.1001fonts.com/licenses/general-font-usage-terms.html). That font is the standard expected for the US and is also used in some other countries. See the [TECHNICAL](./TECHNICAL.md) file for more information on banking standards and check specifications.

SYNOPSIS
========



    %*ENV<CheckwriterPrivateDir> = "/path/to/private/dir";
    use Checkwriter;
    checkwriter write-check [interactive process]

The user's default personal or business bank account and other private information are in the `AccountData.hjson` file, and the records of checks written are in the `Register.json` file. The data to define the physical layout of a printed check are in file `BlankCheck.hjson`. All are shown as examples in the `resources` directory. All the `hjson` input files use the `Hjson` format (see module `JSON::Hjson` for more information).

Planned features
----------------

  * Ability to print multiple checks in one batch

  * Ability to use other standard check papers

  * Ability to use multiple checking accounts

  * Ability to use other fonts and currency symbols for other world regions

Contributing
------------

Interested users are encouraged to contribute improvements and corrections to this module. Pull requests (PRs), bug reports, feature requests, and suggestions are always welcome.

LICENSE and COPYRIGHT
=====================

Artistic 2.0. See [LICENSE](./LICENSE).

© 2020-2023, Thomas M. Browder, Jr. <tbrowder@acm.org>

