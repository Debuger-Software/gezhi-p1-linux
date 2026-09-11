# GEZHI P1 Linux

A tiny Linux setup for the **GEZHI P1** thermal label printer.

This project was created after reverse-engineering the printer enough to use it directly over USB without the Eleph-label Android app or a vendor Windows driver.

## Tested printer

The unit used during development identifies over USB as:

```text
0483:5720 STMicroelectronics Mass Storage Device
```

but its USB descriptors reveal:

```text
Manufacturer: GEZHI
Product: P1
Serial: USB001
Interface Class: Printer
```

The printer accepts **TSPL** commands over USB.

## What this installs

- CUPS
- Pillow (`python3-pil`)
- a RAW CUPS queue named `GEZHI_P1`
- `/usr/local/bin/label-print`

## Install

Connect and power on the printer, then run:

```bash
chmod +x install.sh
./install.sh
```

The installer uses `nala` when available, otherwise `apt-get`.

## Print

```bash
label-print my-label.png
```

You can also check the configured queue:

```bash
label-print --check
```

## Recommended image size

The physical labels used during testing were:

```text
50 x 30 mm
```

The calibrated bitmap area that printed cleanly on the tested P1 was:

```text
380 x 220 px
```

For predictable results, prepare artwork directly at **380×220 px**.

Other image sizes are accepted and are scaled proportionally to fit inside that area.

Supported formats depend on Pillow and normally include PNG, JPEG, WebP, BMP and more.

## Data path

```text
image
  ↓
Pillow
  ↓
1-bit bitmap
  ↓
TSPL BITMAP
  ↓
CUPS RAW queue
  ↓
USB
  ↓
GEZHI P1
```

## Important implementation detail

The tested printer uses the opposite bitmap polarity from what was initially expected:

```text
white = 1
black = 0
```

The `label-print` script handles this automatically.

## Notes

The installer tries to discover the printer URI with:

```bash
lpinfo -v
```

and falls back to:

```text
usb:///P1?serial=USB001
```

if discovery fails.

CUPS RAW queues are deprecated upstream and may disappear in a future CUPS release. For current Debian/Ubuntu-family systems they still work and provide a simple direct path for TSPL data.

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Dependencies are intentionally left installed.

## License

MIT
