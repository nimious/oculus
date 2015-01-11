# io-oculus
Nim bindings for the Oculus VR SDK.

![io-spacenav Logo](logo.png)

## About

io-oculus contains bindings to the Oculus SDK (libovr) for the Nim programming
language. Oculus provides virtual reality head-mounted displays and positional
tracking devices, such as the Rift, DK1, DK2 and GearVR.


## Supported Platforms

io-oculus is still under heavy development and does not work yet!


## Prerequisites

To compile the bindings in this package you must have **libovr**, the Oculus VR
SDK library, installed on your computer. Users of your program also need to
install the device drivers, which can be downloaded from the Oculus web site.

### Linux

If your Linux distribution includes a package manager or community repository,
it may already have pre-compiled binaries for both the Daemon and the SDK. For
example, on ArchLinux the driver, udev rules and SDK are available in AUR (see
[ArchWiki](https://wiki.archlinux.org/index.php/Oculus_Rift) for details).

Alternatively, you can download the SDK from the Oculus developer web site and
follow its instructions to manually build and install it.

### Mac OSX

TODO

### Windows

TODO


## Dependencies

io-oculus does not have any dependencies to other Nim packages at this time.


## Usage


## Support

Please [file an issue](https://github.com/nimious/io-oculus/issues), submit a
[pull request](https://github.com/nimious/io-oculus/pulls?q=is%3Aopen+is%3Apr)
or email us at info@nimio.us if this package is out of date or contains bugs.
For all other issues related to Oculus devices or the device driver software
visit the Oculus web sites below.


## References

- [Oculus Homepage](https://www.oculus.com)
- [Oculus SDK Download Page](https://developer.oculus.com/downloads/)
