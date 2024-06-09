[![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions) [![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions) [![Actions Status](https://github.com/tbrowder/Checkwriter/actions/workflows/windows-spec.yml/badge.svg)](https://github.com/tbrowder/Checkwriter/actions)

Checkwriter
===========

Using templates similar to the format of the check (*.chk) files of [GnuCash](https://gnucash.org), this module and its binary programs allows the user to print checks on standard sizes of paper.

The default is to print a single check on Office Depot's single-check paper (US Letter size) using the provided check template file. The font used is the **E-13B, Common Machine Language font** in a free (for non-commercial use) implementation called the *MICR Encoding Font* provided by **[1001 Fonts](https://www.1001fonts.com/micr-encoding-font.html#styles)** with reasonable [terms of use](https://www.1001fonts.com/licenses/general-font-usage-terms.html). That font is the standard expected for the US and is also used in some other countries. See the [TECHNICAL](./TECHNICAL.md) file for more information on banking standards and check specifications.

SYNOPSIS
========



    %*ENV<CHECKWRITER_PRIVATE_DIR> = "/path/to/private/dir";
    use Checkwriter;
    checkwriter write-check [interactive process]

DESCRIPTION
===========



The user's default personal or business bank account and other private information are in the files represented by the files in the 'resources' directory:

  * 'account.hjson'

    Contains the bank account data. 

  * 'register.json'

    Contains records of checks written.

  * 'check.hjson'

    Contains the data to define the physical layout of a printed check.

The file names are **not** required to be the same but, in any case, they must be provided in the user's `$HOME/.Checkwriter/config.yml` which will be created if it doesn't exist and be populated with the example names. That default file looks like this:

    # file: $HOME/.Checkwriter/config.yml
    #   file names:
    account-data:  account.yml
    check-data:    check.hjson
    register-data: register.json

All are shown as examples in the `resources` directory. All the `.hjson` input files use the `Hjson` format (see module `JSON::Hjson` for more information) and the `.yml` files use the `YAML` format (see module `YAMLish` for more information).

Customization
-------------

The user is provided usable templates in the 'user-check-data.hjson' and 'user-account-data.hjson' files for his or her own use to print checks on the Office Depot check paper. Merely change the personal data to that desired. The 'user-register.json' file will be populated as checks are written.

Usage
-----

After customizing your account and check data as discussed above, you are ready to print a test check to see if all data are correct.

For non-US use
--------------

The author is happy to ensure everyone can use Checkwriter. 

Non-western languages can be accomodated, but it will take a while to determine your exact needs. It would be best to use personal email and one of the Raku IRC channels for coordination.

Note the check writing dialog has an option to allow the user to enter the text to be used for the amount in words. There is also a field in the '' file to specify the currency symbol by actual character or its hexadecimal code.

In all cases, the following must be specified:

  * Size of the paper to be used (width X height)

  * Size of the desired check image (width X height)

  * Origin of the lower-left corner of the desired check image's location on the paper relative to the lower left corner of the paper (0, 0)

All dimensions should be given in PostScript points (72 per inch)

To do so, interested parties will have to help in the following ways:

  * Install the Freefonts on your system (Debian package 'free-fonts-otf'). 

  * Provide the complete path to your desired font as installed on your system.

  * Provide the width and length of the desired check image (in PostScript points: 72 points per inch).

To use the module for non-US countries, you can install the Freefont Serif, Sans, and Mono fonts (Debian package 'free-fonts-otf'). Then install (or reinstall) this package.

Planned features
----------------

  * Ability to print multiple checks in one batch

  * Ability to use other standard check papers

  * Ability to use multiple checking accounts

  * Ability to use other fonts and currency symbols for other world regions

If any person is interested in making this program more useful for non-US use, he or she can help by providing 

Contributing
------------

Interested users are encouraged to contribute improvements and corrections to this module. Pull requests (PRs), bug reports, feature requests, and suggestions are always welcome.

LICENSE and COPYRIGHT
=====================

Artistic 2.0. See [LICENSE](./LICENSE).

© 2020-2024, Thomas M. Browder, Jr. <tbrowder@acm.org>

