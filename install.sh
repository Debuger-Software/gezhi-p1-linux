#!/usr/bin/env bash
set -euo pipefail

PRINTER_NAME="GEZHI_P1"
VIDPID="0483:5720"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="label-print"

say() { printf '\n==> %s\n' "$*"; }
warn() { printf '\nWARNING: %s\n' "$*" >&2; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "Run this script as a normal user, not directly as root. It will use sudo when needed."

command -v sudo >/dev/null 2>&1 || die "sudo is required."

say "Installing dependencies"

if command -v nala >/dev/null 2>&1; then
    sudo nala install cups cups-client python3-pil usbutils
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y cups cups-client python3-pil usbutils
else
    die "Unsupported package manager. Install cups, cups-client, python3-pil and usbutils manually."
fi

say "Starting CUPS"
sudo systemctl enable --now cups

say "Installing label-print"
sudo install -m 0755 "$(dirname "$0")/$SCRIPT_NAME" "$INSTALL_DIR/$SCRIPT_NAME"

say "Looking for GEZHI P1"

if lsusb | grep -qi "$VIDPID"; then
    echo "GEZHI P1 detected as USB $VIDPID."
else
    warn "USB device $VIDPID is not visible right now. The queue can still be created if the printer backend exposes it."
fi

URI="$(lpinfo -v 2>/dev/null | awk '/direct usb:\/\/\/P1/ {print $2; exit}')"

if [[ -z "$URI" ]]; then
    URI="usb:///P1?serial=USB001"
    warn "Could not auto-detect the CUPS USB URI. Falling back to: $URI"
fi

say "Creating CUPS RAW queue: $PRINTER_NAME"
sudo lpadmin -x "$PRINTER_NAME" 2>/dev/null || true
sudo lpadmin -p "$PRINTER_NAME" -E -v "$URI" -m raw

say "Checking queue"
lpstat -p "$PRINTER_NAME" -l || true

cat <<EOF

Installation complete.

Usage:
  label-print image.png

Check:
  label-print --check

Recommended artwork size:
  380x220 px

Physical label:
  50x30 mm

CUPS queue:
  $PRINTER_NAME

EOF
