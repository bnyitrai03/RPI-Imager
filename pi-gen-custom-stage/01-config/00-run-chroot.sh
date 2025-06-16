#!/bin/bash -e

echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Added dtparam=ant2 to /boot/firmware/config.txt"

raspi-config nonint do_wifi_country HU
echo "Set WiFi country to HU"

# Load WiFi configuration
if [ -f "/wifi-config" ]; then
    source "/wifi-config"
    echo "Loaded WiFi config from /wifi-config for SSID: $WIFI_SSID"
elif [ -f "./wifi-config" ]; then
    source "./wifi-config"
    echo "Loaded WiFi config from ./wifi-config for SSID: $WIFI_SSID"
elif [ -f "../wifi-config" ]; then
    source "../wifi-config"
    echo "Loaded WiFi config from ../wifi-config for SSID: $WIFI_SSID"
else
    echo "Error: WiFi config file not found"
    echo "Current directory contents:"
    ls -la
    exit 1
fi

if [ -z "$WIFI_SSID" ] || [ -z "$WIFI_PASS" ]; then
    echo "Error: WIFI_SSID or WIFI_PASS is empty"
    exit 1
fi

# Configure WiFi using NetworkManager connection file
uuid=$(cat /proc/sys/kernel/random/uuid)
tee "/etc/NetworkManager/system-connections/$WIFI_SSID.nmconnection" > /dev/null << EOF
[connection]
id=$WIFI_SSID
uuid=$uuid
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
