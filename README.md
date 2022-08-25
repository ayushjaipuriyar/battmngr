# Vantage for 14are05

![made for ideapad](https://img.shields.io/badge/made%20for-ideapad-blue) ![license](https://img.shields.io/github/license/0xless/vantage)

Battery manager to handle system performance modes and charge modes through acpi_calls (for ideapad 14are05).

<!-- ![demo](img/demo.gif) -->

## Motivation

On Windows native software to support battery and performance operations exist, on GNU/Linux, it's possible to handle system performance modes and battery charge modes making `acpi_calls` [manually](https://wiki.archlinux.org/title/Lenovo_IdeaPad_5_14are05#Power_management). This script makes it easy to manage such operations.

## Getting started

### Prerequisites

In order to use vantage the `acpi-call` module needs to be installed.

### Installation

To install `vantage` you only need to download the script, put it in a directory of your choice and then add it to your PATH.

## Usage

```
Usage: vantage [OPTION...] MODE
Options:
        -r, --read             read current battery mode
        -s, --set              set battery mode
        -rc, --read-charge     read current charge mode
        -sc, --set-charge      set charge mode
Battery Modes:
        1        Intelligent Cooling
        2        Extreme Performance
        3        Battery Saving
Charge modes:
        1        Rapid Charge On
        2        Rapid Charge Off
        3        Battery Conservation On
        4        Battery Conservation Off
Examples:
        vantage -r
        vantage -s 1
        vantage -rc
        vantage -sc 1
        vantage -s 1 -r -sc 4 -rc
```

## Sudo

Since this requires sudo always , the dumb way to make it easier to use, is add the following line to your sudoers file

```sh
sudo visudo
##add the next line to the end of the file
$USER ALL=(ALL) NOPASSWD: /usr/bin/vantage
```

### Note

$USER variable doesnt work in sudoers file by default
Hence you need to change it to your username
If someone knows how to have the variables accessible in sudoers file , please tell me

## Contributing

⚠️**Looking for testers**⚠️ - do you want to use `vantage` on your acpi_calls supported laptop?
Make sure open an issue detailing:

- your laptop model
- the output of: `sudo dmidecode -s system-product-name`
- calls/values for battery related operations (if known)

I'm actively trying to support more devices and I'm in need of someone willing to point out new models `vantage` could support and test experimental verions of the script.

## Note

When in configuration:

- Rapid Charge Off
- Battery Conservation On

issuing the command `vantage -sc 1` will turn on Rapid Charge mode but disable Battery Conservation mode.
It's possible to activate both Rapid Charge and Battery Conservation modes starting from configuration:

- Rapid Charge On
- Battery Conservation Off

and issuing the command `vantage -sc 3`  
This configuration is not obtainable using official lenovo software and should be avoided.

Check here for more: https://wiki.archlinux.org/title/Lenovo_IdeaPad_5_14are05#Note

## License

This project is licensed under the GPL-3.0 License.
