#!/bin/bash -e

echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Added dtparam=ant2 to /boot/firmware/config.txt"

# raspi-config nonint do_wifi_country HU
# echo "Set WiFi country to HU"