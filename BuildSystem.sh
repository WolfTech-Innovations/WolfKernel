#!/bin/bash

# Variables
IMAGE_NAME="WolfOS.iso"
WORK_DIR="/tmp/wolfos_iso"
CHROOT_DIR="$WORK_DIR/chroot"
ARCH="amd64" # Change to i386 for 32-bit systems
COMPILED_KERNEL_PATH="WolfKernel/arch/x86_64/bzImage"
# Ensure compiled kernel file exists
if [[ ! -f "$COMPILED_KERNEL_PATH" ]]; then
    echo "ERROR: Compiled kernel not found at $COMPILED_KERNEL_PATH"
    exit 1
fi

# Install required tools
echo "Installing required tools..."
sudo apt update
sudo apt install -y debootstrap xorriso grub-pc-bin squashfs-tools apt-transport-https wget curl dialog calamares isolinux
echo "Required tools installed."

# Step 1: Create the base system with debootstrap
echo "Creating base system with debootstrap..."
mkdir -p "$CHROOT_DIR"
sudo debootstrap --arch=$ARCH focal "$CHROOT_DIR" http://archive.ubuntu.com/ubuntu
echo "Base system created."

# Step 2: Set up chroot environment
echo "Setting up chroot environment..."
sudo mount --bind /dev "$CHROOT_DIR/dev"
sudo mount --bind /sys "$CHROOT_DIR/sys"
sudo mount --bind /proc "$CHROOT_DIR/proc"
sudo cp /etc/resolv.conf "$CHROOT_DIR/etc/"
echo "Chroot environment set up."

# Step 3: Install KDE, Calamares, and configure the system
echo "Installing KDE, Calamares, and configuring WolfOS..."
sudo chroot "$CHROOT_DIR" /bin/bash <<EOF
apt update
apt install -y kde-plasma-desktop lightdm grub-pc calamares
echo "Welcome to WolfOS!" > /etc/motd
echo "WolfOS" > /etc/hostname
EOF
echo "KDE, Calamares, and configurations installed."

# Step 4: Configure Calamares
echo "Configuring Calamares..."
sudo chroot "$CHROOT_DIR" /bin/bash <<EOF
mkdir -p /etc/calamares
cat <<CAL_CONF > /etc/calamares/settings.conf
---
modules:
    - welcome
    - locale
    - keyboard
    - partition
    - users
    - summary
    - bootloader
    - finished
CAL_CONF

cat <<DESKTOP_ENTRY > /usr/share/applications/calamares.desktop
[Desktop Entry]
Version=1.0
Name=WolfOS Installer
Exec=calamares
Icon=calamares
Terminal=false
Type=Application
Categories=System;Installer;
DESKTOP_ENTRY
EOF
echo "Calamares configured."

# Step 5: Copy the compiled kernel and configure GRUB
echo "Configuring GRUB with compiled kernel..."
sudo cp "$COMPILED_KERNEL_PATH" "$CHROOT_DIR/boot/vmlinux"
sudo chroot "$CHROOT_DIR" /bin/bash <<EOF
update-initramfs -c -k all
grub-install --target=i386-pc --boot-directory=/boot --recheck
update-grub
EOF
echo "GRUB configured with the compiled kernel."

# Step 6: Clean up chroot environment
echo "Cleaning up chroot environment..."
sudo umount -lf "$CHROOT_DIR/dev"
sudo umount -lf "$CHROOT_DIR/sys"
sudo umount -lf "$CHROOT_DIR/proc"
echo "Chroot cleaned up."

# Step 7: Create SquashFS for the live system
echo "Creating SquashFS for the live system..."
mkdir -p "$WORK_DIR/iso/live"
sudo mksquashfs "$CHROOT_DIR" "$WORK_DIR/iso/live/filesystem.squashfs" -e boot
echo "SquashFS created."

# Step 8: Set up ISO boot directory
echo "Setting up boot directory..."
mkdir -p "$WORK_DIR/iso/boot/grub"
sudo cp "$CHROOT_DIR/boot/vmlinux" "$WORK_DIR/iso/boot/vmlinux"
cat <<GRUB > "$WORK_DIR/iso/boot/grub/grub.cfg"
set timeout=10
menuentry "WolfOS Live" {
    linux /boot/vmlinux boot=live quiet splash
}
GRUB
echo "Boot directory configured."

# Step 9: Create ISO
echo "Creating the WolfOS ISO..."
xorriso -as mkisofs -o "$IMAGE_NAME" \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  "$WORK_DIR/iso"
echo "WolfOS ISO created: $IMAGE_NAME"

echo "WolfOS build completed successfully!"
