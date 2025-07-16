#!/usr/bin/env bash

## clone pi-gen raspberry pi build system
git clone --depth 1 --branch 2024-11-19-raspios-bookworm https://github.com/RPI-Distro/pi-gen.git

## disable export for stage2
touch ./pi-gen/stage2/SKIP_IMAGES ./pi-gen/stage2/SKIP_NOOBS

## link config
ln -s ../config ./pi-gen

## link stage2-kiosk
ln -s ../stage2-wgep ./pi-gen

## link future deploys
[[ ! -d ./pi-gen/deploy ]] && mkdir ./pi-gen/deploy
ln -s ./pi-gen/deploy .
