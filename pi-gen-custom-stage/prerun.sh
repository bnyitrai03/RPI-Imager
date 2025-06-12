#!/bin/bash -e

# Ensures the root filesystem from the previous stage is copied
# into the working directory.
if [ ! -d "${ROOTFS_DIR}" ]; then
  copy_previous
fi