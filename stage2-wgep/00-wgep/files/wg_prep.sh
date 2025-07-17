#!/bin/bash

UPDATE_CONFIG=0

get_overlay_now() {
  grep -q "overlayroot=tmpfs" /proc/cmdline
  echo $?
}

disable_overlay() {
if [ "$(get_overlay_now)" -eq 0 ] ; then
    raspi-config nonint disable_overlayfs
    echo "overlay disabled"
    #reboot
else
    # Overlay is already disabled. Wireguard config updates can be applied
    UPDATE_CONFIG=1
fi
}

enable_overlay() {
if [ "$(get_overlay_now)" -eq 1 ] ; then
    raspi-config nonint enable_overlayfs
    echo "overlay enabled"
    #reboot
fi
}

#check for config

WG_CONFIG_DIR='/boot/firmware/'
WG_CONFIG="${WG_CONFIG_DIR}/wg_config.txt"

if [ ! -f "${WG_CONFIG}" ]; then
    echo "Config file not found. Boot interrupted" >&2
    exit 1
else
    # shellcheck disable=SC1090
    . "${WG_CONFIG}"
fi

# check for mandatory config parameter
if [ -z "${WG_SERVER_PUBKEY}" ]; then
    echo "Wireguard server public key not set. Boot interrupted" >&2
    exit 1
fi

if [ -z "${WG_SERVER_URL}" ]; then
    echo "Wireguard server url or ip not set. Boot interrupted" >&2
    exit 1
fi

# check for wg keys
WG_KEY_DIR='/etc/wireguard/'
WG_DEFAULT_PRIVKEY='wg0.key'
WG_DEFAULT_PUBKEY='wg0.pub'
WG_CONFIG='wg0.conf'

if [ -z "${WG_CLIENT_PRIVKEY}" ]; then
    WG_CLIENT_PRIVKEY="${WG_DEFAULT_PRIVKEY}"
fi
if [ -f "${WG_CONFIG_DIR}/${WG_CLIENT_PRIVKEY}" ]; then
    disable_overlay
    echo "Wireguard client private key file found for deployment"
    umask 077; cp "${WG_CONFIG_DIR}/${WG_CLIENT_PRIVKEY}" "${WG_KEY_DIR}/${WG_DEFAULT_PRIVKEY}"
elif [ ! -f "${WG_KEY_DIR}/${WG_DEFAULT_PRIVKEY}" ]; then
    disable_overlay
    echo "No Wireguard client private key found. Generating new keypair"
    wg genkey > "${WG_KEY_DIR}/${WG_DEFAULT_PRIVKEY}"
    wg pubkey < "${WG_KEY_DIR}/${WG_DEFAULT_PRIVKEY}" > "${WG_KEY_DIR}/${WG_DEFAULT_PUBKEY}"
elif [ ! -f "${WG_KEY_DIR}/${WG_DEFAULT_PUBKEY}" ]; then
    disable_overlay
    echo "Public key missing for wireguard client. Generating public key from existing private key"
    wg pubkey < "${WG_KEY_DIR}/${WG_DEFAULT_PRIVKEY}" > "${WG_KEY_DIR}/${WG_DEFAULT_PUBKEY}"
fi

if [ -z "${WG_CLIENT_PUBKEY}" ]; then
    WG_CLIENT_PUBKEY="${WG_DEFAULT_PUBKEY}"
fi
if [ -f "${WG_CONFIG_DIR}/${WG_CLIENT_PUBKEY}" ]; then
    disable_overlay
    echo "Wireguard client public key file found for deployment"
    umask 077; cp "${WG_CONFIG_DIR}/${WG_CLIENT_PUBKEY}" "${WG_KEY_DIR}/${WG_DEFAULT_PUBKEY}"
fi

echo "Current public key for wireguard server is ${WG_CLIENT_PUBKEY}" > /etc/issue

# identify gateway interface
GATEWAY_INTERFACE=$(ip -o route get 8.8.8.8 | perl -nle 'if ( /dev\s+(\S+)/ ) {print $1}')

if [ "${GATEWAY_INTERFACE}" = "lo" ]; then
    echo "No default route found. Probably no internet access"
    exit 1
fi

# reapply wireguard config
if [ "$UPDATE_CONFIG" -eq 1 ]; then
    export GATEWAY_INTERFACE="${GATEWAY_INTERFACE}"
    export $(grep -v '^#' ${WG_CONFIG} | xargs -d '\n')
    envsubst < "${WG_CONFIG}.template" > "${WG_CONFIG}"
    nmcli connection import type wireguard file "${WG_CONFIG}"
fi

enable_overlay
