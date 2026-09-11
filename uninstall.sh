#!/usr/bin/env bash
set -euo pipefail

PRINTER_NAME="GEZHI_P1"

echo "Removing label-print..."
sudo rm -f /usr/local/bin/label-print

echo "Removing CUPS queue..."
sudo lpadmin -x "$PRINTER_NAME" 2>/dev/null || true

echo "Done."
echo "Dependencies were intentionally left installed."
