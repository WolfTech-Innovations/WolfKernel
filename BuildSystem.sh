#!/bin/bash

# BUILD SCRIPT FOR DISTROBUTION

# Variables
IMAGE_NAME="WolfOS.iso"
WORK_DIR="/tmp/wolfos_iso"
CHROOT_DIR="$WORK_DIR/chroot"
ARCH="amd64" # Change to i386 for 32-bit systems
COMPILED_KERNEL_PATH="/path/to/compiled/kernel/vmlinux" # Replace with your kernel path

# Pretty print functions
function step() { echo -e "\033[1;34m[Step] $1...\033[0m"; }
function success() { echo -e "\033[1;32m[Success] $1!\033[0m"; }
function error() { echo -e "\033[1;31m[Error] $1\033[0m"; exit 1; }
function progress() { echo -ne "\033[1;36m$1\r\033[0m"; sleep 0.1; }

# Check kernel file
if [[ ! -f "$COMPILED_KERNEL_PATH" ]]; then
    error "Compiled kernel not found at $COMPILED_KERNEL_PATH"
fi

# Ensure necessary tools are installed
step "Installing required tools"
sudo apt update
sudo apt install -y debootstrap xorriso grub-pc-bin squashfs-tools apt-transport-https wget curl dialog calamares
success "Tools installed"

# Step 1: Create the base system with debootstrap
step "Creating base system with debootstrap"
mkdir -p "$CHROOT_DIR"
progress "Starting debootstrap..."
sudo debootstrap --arch=$ARCH focal "$CHROOT_DIR" http://archive.ubuntu.com/ubuntu || error "Debootstrap failed"
success "Base system created"

# Step 2: Set up chroot environment
step "Setting up chroot environment"
sudo mount --bind /dev "$CHROOT_DIR/dev"
sudo mount --bind /sys "$CHROOT_DIR/sys"
sudo mount --bind /proc "$CHROOT_DIR/proc"
sudo cp /etc/resolv.conf "$CHROOT_DIR/etc/"
success "Chroot environment set up"

# Step 3: Install KDE, Calamares, and additional packages
step "Installing KDE, Calamares, and configuring WolfOS"
sudo chroot "$CHROOT_DIR" /bin/bash <<EOF
apt update
apt install -y kde-plasma-desktop lightdm grub-pc calamares
echo "Welcome to WolfOS!" > /etc/motd
echo "WolfOS" > /etc/hostname
EOF
success "KDE, Calamares, and basic configurations installed"

# Step 4: Configure Calamares
step "Configuring Calamares"
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
success "Calamares configured"

# Step 5: Copy the compiled kernel and configure GRUB
step "Configuring GRUB with compiled kernel"
sudo cp "$COMPILED_KERNEL_PATH" "$CHROOT_DIR/boot/vmlinux"
sudo chroot "$CHROOT_DIR" /bin/bash <<EOF
update-initramfs -c -k all
grub-install --target=i386-pc --boot-directory=/boot --recheck
update-grub
EOF
success "GRUB configured with the compiled kernel"

# Step 6: Clean up chroot environment
step "Cleaning up chroot environment"
sudo umount -lf "$CHROOT_DIR/dev"
sudo umount -lf "$CHROOT_DIR/sys"
sudo umount -lf "$CHROOT_DIR/proc"
success "Chroot cleaned up"

# Step 7: Create SquashFS for live system
step "Creating SquashFS for live system"
mkdir -p "$WORK_DIR/iso/live"
sudo mksquashfs "$CHROOT_DIR" "$WORK_DIR/iso/live/filesystem.squashfs" -e boot || error "SquashFS creation failed"
success "SquashFS created"

# Step 8: Set up ISO boot directory
step "Setting up boot directory"
mkdir -p "$WORK_DIR/iso/boot/grub"
sudo cp "$CHROOT_DIR/boot/vmlinux" "$WORK_DIR/iso/boot/vmlinux"
sudo cp "$CHROOT_DIR/boot/initrd.img-"* "$WORK_DIR/iso/boot/initrd"
cat <<GRUB > "$WORK_DIR/iso/boot/grub/grub.cfg"
set timeout=10
menuentry "WolfOS Live" {
    linux /boot/vmlinux boot=live quiet splash
    initrd /boot/initrd
}
GRUB
success "Boot directory configured"

# Step 9: Create ISO
step "Building the WolfOS ISO"
progress "Creating ISO image..."
xorriso -as mkisofs -o "$IMAGE_NAME" \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -c boot.cat -b boot/grub/i386-pc/core.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  "$WORK_DIR/iso" || error "ISO creation failed"
success "WolfOS ISO built successfully!"

echo -e "\033[1;32mWolfOS is ready with Calamares installer! ISO file: $IMAGE_NAME\033[0m"