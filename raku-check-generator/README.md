# Raku Check Generator

This project creates printable PDF bank checks with MICR line, logo, preview, and optional printing.

## Requirements

- Raku installed (see https://raku.org/download)
- `zef` (Raku module installer)
- Raku module: `PDF::Lite`
- For GUI (optional): `zenity` (on Linux desktops)
- For printing: a working CUPS (`lp`) setup on Linux/macOS, or Acrobat Reader on Windows

You can use the provided `install.sh` script on Debian/Ubuntu-like systems to install dependencies.

## Files

- `check-generator.raku` — main script (CLI + interactive)
- `check-gui.sh` — simple GUI front-end (uses zenity; Linux only)
- `install.sh` — helper to install dependencies
- `MICR.ttf` — **placeholder** MICR E-13B font file (see `FONTS-LICENSE.md`)
- `logo.png` — placeholder logo image (replace with your real logo)
- `README.md` — this file
- `FONTS-LICENSE.md` — notes about MICR font licensing

## Usage

### 1. Install dependencies

On Debian/Ubuntu-like systems:

```sh
chmod +x install.sh
./install.sh
```

Or manually:

```sh
zef install PDF::Lite
# Optionally:
sudo apt-get install zenity
```

### 2. Run from CLI

Interactive mode:

```sh
raku check-generator.raku
```

With command-line options:

```sh
raku check-generator.raku --today --payee="John Doe" --amount=123.45 --preview
```

Print directly to default printer:

```sh
raku check-generator.raku --today --payee="John Doe" --amount=123.45 --print
```

List printers:

```sh
raku check-generator.raku --list-printers
```

Print to a specific printer:

```sh
raku check-generator.raku --today --payee="John Doe" --amount=123.45 --print --printer="HP_LaserJet"
```

### 3. Simple GUI (Linux + zenity)

```sh
chmod +x check-gui.sh
./check-gui.sh
```

The GUI will prompt for the main fields, then call `check-generator.raku` and show a preview of the generated check.

## Notes

- Replace `logo.png` with your own logo.
- Replace `MICR.ttf` with a properly licensed MICR E-13B font as described in `FONTS-LICENSE.md` before using real checks.
- Always test alignment on your printer and check stock before using for real banking purposes.
