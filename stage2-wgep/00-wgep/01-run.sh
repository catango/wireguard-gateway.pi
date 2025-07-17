#!/bin/bash -e

# install config
install -m 644 -o 0 -g 0 files/wg_config.txt "${ROOTFS_DIR}/boot/firmware/"

# install wireguard files
install -m 644 -o 0 -g 0 files/wg_prep.service "${ROOTFS_DIR}/etc/systemd/system/"
install -m 755 -o 0 -g 0 files/wg_prep.sh "${ROOTFS_DIR}/usr/local/bin/"
install -m 755 -o 0 -g 0 files/write_etc_issue.sh "${ROOTFS_DIR}/usr/local/bin/"

install -m 644 -o 0 -g 0 files/wg0.conf.template "${ROOTFS_DIR}/etc/wireguard/"
install -m 644 -o 0 -g 0 files/70-wireguard-routing.conf "${ROOTFS_DIR}/etc/sysctl.d/"

#install -m 755 -o 0 -g 0 -d "${ROOTFS_DIR}/etc/systemd/system/wg-quick@.service.d/"
#install -m 644 -o 0 -g 0 files/wg_override "${ROOTFS_DIR}/etc/systemd/system/wg-quick@.service.d/override.conf"

#install -m 644 -o 0 -g 0 files/wireguard_reresolve-dns.timer "${ROOTFS_DIR}/etc/systemd/system/"
#install -m 644 -o 0 -g 0 files/wireguard_reresolve-dns.service "${ROOTFS_DIR}/etc/systemd/system/"

# install bind9 config
install -m 644 files/named.conf.options "${ROOTFS_DIR}/etc/bind/"
