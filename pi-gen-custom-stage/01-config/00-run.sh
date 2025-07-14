#!/bin/bash -e

on_chroot << EOF
echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Enabled Antenna"

raspi-config nonint do_wifi_country HU
echo "Set WiFi country to HU"
EOF

install -v -m 600 files/main.nmconnection ${ROOTFS_DIR}/etc/NetworkManager/system-connections/
on_chroot << EOF
chown root:root /etc/NetworkManager/system-connections/main.nmconnection
echo "Configured WiFi connection"
EOF

on_chroot << EOF
mkdir -p /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/rpicm5.key \
  -out /etc/nginx/ssl/rpicm5.crt \
  -subj "/C=HU/ST=Budapest/L=Budapest/O=SZTAKI/CN=rpicm5"
EOF

# Configure nginx
install -v -m 644 files/baby-monitor-nginx.conf ${ROOTFS_DIR}/etc/nginx/sites-available/
on_chroot << EOF
ln -s /etc/nginx/sites-available/baby-monitor-nginx.conf /etc/nginx/sites-enabled/baby-monitor-nginx.conf
rm -f /etc/nginx/sites-enabled/default
echo "Nginx is configured"
EOF

# Create virtual camera devices
on_chroot << EOF
echo "v4l2loopback" | tee /etc/modules-load.d/v4l2loopback.conf
echo 'options v4l2loopback devices=6 video_nr=10,11,12,14,15,16 card_label="Cam1,CamL1,CamR1,Cam2,CamL2,CamR2"' | tee /etc/modprobe.d/v4l2loopback-options.conf
EOF

# Install Services, which are linked as a git module
# Create a venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r /BabyMonitor/requirements.txt


# Create a systemd for the services