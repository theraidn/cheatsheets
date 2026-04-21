#!/bin/bash

# Decrypt and mount LUKS2 encrypted USB drive

set -e

DEVICE="MYDEVDEVICE"
MOUNT_POINT="/my/mount/point"
LUKS_NAME="LUKS_NAME"

# Check if mount point exists
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Error: Mount point $MOUNT_POINT does not exist."
    exit 1
fi

# Check if device exists
if [ ! -b "$DEVICE" ]; then
    echo "Error: Device $DEVICE not found."
    exit 1
fi

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    echo "USB drive is already mounted at $MOUNT_POINT"
    exit 0
fi

# Prompt for passphrase and open LUKS2
echo "Opening LUKS2 encrypted device..."
sudo cryptsetup open "$DEVICE" "$LUKS_NAME"

# Mount the decrypted device
echo "Mounting decrypted device..."
sudo mount "/dev/mapper/$LUKS_NAME" "$MOUNT_POINT"

echo "Success! USB drive mounted at $MOUNT_POINT"
exit 0
