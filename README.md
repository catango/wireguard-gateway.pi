# MusicBoxPi

A tool based on [pi-gen](https://github.com/RPi-Distro/pi-gen)
to build simple Raspberry Pi OS images for simple music player.

Inspired by Nico Kaiser's simple audio receiver https://github.com/nicokaiser/rpi-audio-receiver

## Usage

Use Ubuntu or other Debian-based systems

# required dependencies for pi-gen build on plain debian:
quilt parted qemu-user-static debootstrap zerofree zip dosfstools libarchive-tools rsync xz-utils curl xxd file bc gpg pigz arch-test

An apt proxy may be configured to speed up building

```bash
git clone --depth 1 https://github.com/catango/musicbox.pi.git
./init.sh

# install build dependencies, if not installed yet. Reboot may be required to load all kernel modules properly
sudo apt install quilt parted qemu-user-static debootstrap zerofree zip dosfstools libarchive-tools rsync xz-utils curl xxd file bc gpg pigz arch-test

sudo ./build.sh
```

For further details refer to:
- pi-gen: https://github.com/RPi-Distro/pi-gen

## Enjoy 🥂
