#!/bin/bash -e

on_chroot << EOF
echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Enabled Antenna"

raspi-config nonint do_wifi_country HU
echo "Set WiFi country to HU"
EOF

install -v -m 600 files/main.nmconnection ${ROOTFS_DIR}/etc/NetworkManager/system-connections/
chown root:root /etc/NetworkManager/system-connections/main.nmconnection
echo "Configured WiFi connection"