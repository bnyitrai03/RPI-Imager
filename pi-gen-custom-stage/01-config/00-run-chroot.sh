#!/bin/bash -e

echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Added dtparam=ant2 to /boot/firmware/config.txt"

raspi-config nonint do_wifi_country HU
echo "Set WiFi country to HU"

# Configure WiFi using NetworkManager connection file
tee "/etc/NetworkManager/system-connections/$WIFI_SSID.nmconnection" > /dev/null << EOF
[connection]
id=$WIFI_SSID
uuid=$(uuidgen)
type=wifi
autoconnect=true

[wifi]
ssid=$WIFI_SSID

[wifi-security]
key-mgmt=wpa-psk
psk=$WIFI_PASS

[ipv4]
method=auto

[ipv6]
method=auto
EOF

chmod 600 "/etc/NetworkManager/system-connections/$WIFI_SSID.nmconnection"
echo "Created WiFi connection for $WIFI_SSID network"