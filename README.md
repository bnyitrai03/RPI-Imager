# RPI-Imager

[![Build Custom ARM64 Lite Image](https://github.com/bnyitrai03/RPI-Imager/actions/workflows/image_gen.yaml/badge.svg)](https://github.com/bnyitrai03/RPI-Imager/actions/workflows/image_gen.yaml)

A GitHub Actions-based tool for building custom Raspberry Pi images with pre-configured WiFi, SSH access, and custom packages. This tool uses [pi-gen-action](https://github.com/usimd/pi-gen-action) to create bootable Raspberry Pi OS images tailored for specific use cases.

## Setup

### 1. Configure Repository Secrets

Go to your repository's **Settings > Secrets and variables > Actions** and add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `WIFI_SSID` | Your WiFi network name | `MyHomeNetwork` |
| `WIFI_PASS` | Your WiFi password | `MyWiFiPassword123` |
| `HOSTNAME` | Device hostname | `baby-monitor` |
| `USERNAME` | Username | `pi` |
| `PASSWORD` | User password | `raspberry` |
| `SSH_KEY` | Your SSH public key | `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5A...` |

## Usage

### Building a Custom Image

1. **Navigate to Actions**: Go to the **Actions** tab in your GitHub repository

2. **Select Workflow**: Click on "Build Custom ARM64 Lite Image"

3. **Run Workflow**: 
   - Click "Run workflow"
   - Enter a version number (e.g., `v1.0.0`)
   - Click "Run workflow"

4. **Monitor Progress**: The build process takes approximately 30-40 minutes

5. **Download Image**: Once complete, the image will be available in:
   - **Releases**: Permanent download with version tag

### Flashing the Image

1. **Download** the `.zip` file from the GitHub release
2. **Follow this tutorial**:
    - [How to Install OS on Raspberry Pi Compute Module 5 with eMMC Storage](https://smarthomecircle.com/how-to-install-os-on-raspberry-pi-compute-module-5-emmc-storage)

## Customization

### Adding Custom Debian Packages

Edit `pi-gen-custom-stage/00-install-packages/00-packages`:

```
avahi-utils
python3-zeroconf
# Add your packages here
nodejs
nginx
```

### Custom Configuration Scripts

Modify `pi-gen-custom-stage/01-config/00-run.sh` to add custom configurations:

```bash
#!/bin/bash -e

on_chroot << EOF
# Your custom commands here
echo "dtparam=ant2" >> /boot/firmware/config.txt
echo "Enabled Antenna"

# Example: Disable WiFi
echo "dtoverlay=disable-wifi" >> /boot/firmware/config.txt
EOF
```

### Changing Localization

In the workflow file (`.github/workflows/image_gen.yaml`), modify:

```yaml
# Localization settings
timezone: 'America/New_York'
keyboard-keymap: 'us'
keyboard-layout: 'English (US)'
wpa-country: 'US'
```

## Project Structure

```
├── .github/
│   └── workflows/
│       └── image_gen.yaml          # Main workflow file
├── pi-gen-custom-stage/
│   ├── 00-install-packages/
│   │   └── 00-packages             # Package list
│   ├── 01-config/
│   │   ├── 00-run.sh              # Configuration script
│   │   └── files/                  # Configuration files
│   └── prerun.sh                   # Stage preparation
└── README.md
```
