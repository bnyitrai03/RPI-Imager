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
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
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

# Install Services
install -v -d ${ROOTFS_DIR}/opt/BabyMonitor
cp -r files/Services/CameraManagerService ${ROOTFS_DIR}/opt/BabyMonitor/CameraManagerService
cp -r files/Services/StreamingService ${ROOTFS_DIR}/opt/BabyMonitor/StreamingService

# Create virtual environments and install dependencies
on_chroot << EOF
cd /opt/BabyMonitor/CameraManagerService
python3 -m venv .camera_venv
source .camera_venv/bin/activate
pip install -r requirements.txt
deactivate
echo "Installed CameraManagerService with dependencies"

cd /opt/BabyMonitor/StreamingService
python3 -m venv .stream_venv
source .stream_venv/bin/activate
pip install -r requirements.txt
deactivate
echo "Installed StreamingService with dependencies"

chown -R "${FIRST_USER_NAME}:${FIRST_USER_NAME}" /opt/BabyMonitor
EOF

# Create systemd services
cat > ${ROOTFS_DIR}/etc/systemd/system/BabyMonitor-CameraManager.service << EOF
[Unit]
Description=Baby Monitor Camera Manager Service
After=network.target

[Service]
Type=simple
User=${FIRST_USER_NAME}
WorkingDirectory=/opt/BabyMonitor/CameraManagerService
ExecStart=/opt/BabyMonitor/CameraManagerService/.camera_venv/bin/python -m uvicorn src.config_api:app --host 127.0.0.1 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF
echo "CameraManagerService created"

cat > ${ROOTFS_DIR}/etc/systemd/system/BabyMonitor-Streaming.service << EOF
[Unit]
Description=Baby Monitor Video Streaming Service
After=network.target

[Service]
Type=simple
User=${FIRST_USER_NAME}
WorkingDirectory=/opt/BabyMonitor/StreamingService
ExecStart=/opt/BabyMonitor/StreamingService/.stream_venv/bin/python -m uvicorn src.streaming_api:app --host 127.0.0.1 --port 8002
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

EOF
echo "StreamingService created"
echo "Image customization done"

# on_chroot << EOF
# systemctl enable BabyMonitor-CameraManager.service
# systemctl enable BabyMonitor-Streaming.service
# echo "Enabled systemd services"
# EOF