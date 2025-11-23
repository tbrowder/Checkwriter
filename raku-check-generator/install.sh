#!/usr/bin/env bash
set -e

echo "=== Raku Check Generator Installer ==="

# Detect OS (very roughly)
if command -v apt-get >/dev/null 2>&1; then
    PKG_MGR="apt-get"
    echo "Detected Debian/Ubuntu-like system."
else
    PKG_MGR=""
    echo "Non-Debian system detected. This script only knows how to use apt-get."
fi

echo
echo "Step 1: Ensure Raku and zef are installed."
if ! command -v raku >/dev/null 2>&1; then
    echo "WARNING: 'raku' is not found in PATH."
    echo "Please install Raku from https://raku.org/download and re-run this script."
else
    echo "Raku found: $(which raku)"
fi

if ! command -v zef >/dev/null 2>&1; then
    echo "WARNING: 'zef' is not found in PATH."
    echo "Please install zef (Raku module installer) and re-run this script."
else
    echo "zef found: $(which zef)"
fi

echo
echo "Step 2: Install PDF::Lite via zef"
if command -v zef >/dev/null 2>&1; then
    zef install PDF::Lite || {
        echo "ERROR: Failed to install PDF::Lite. Please resolve zef issues and try again."
        exit 1
    }
else
    echo "Skipping PDF::Lite install because zef is missing."
fi

echo
echo "Step 3 (optional): Install zenity for GUI wrapper"
if [ -n "$PKG_MGR" ]; then
    read -p "Install zenity for GUI (y/N)? " yn
    case "$yn" in
        [Yy]*)
            sudo $PKG_MGR update
            sudo $PKG_MGR install -y zenity
            ;;
        *)
            echo "Skipping zenity install."
            ;;
    esac
else
    echo "Package manager not recognized; install zenity manually if desired."
fi

echo
echo "Done. You can now run:"
echo "  raku check-generator.raku"
echo "or (GUI):"
echo "  ./check-gui.sh"
