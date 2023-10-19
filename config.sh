#!/bin/bash

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Remove duplicate boot images
#--------------------------------------
rm /boot/vmlinuz* || true
rm /boot/initramfs* || true

#======================================
# Enable virtio driver
#--------------------------------------
echo "virtio_net" >>/etc/modules
echo "virtio_gpu" >>/etc/modules
echo "virtio_input" >>/etc/modules

#======================================
# Enable init services
#--------------------------------------
ln -s ../modules /etc/dinit.d/boot.d
ln -s ../udhcpc /etc/dinit.d/boot.d
ln -s ../ttyInit /etc/dinit.d/boot.d
ln -s ../seatd /etc/dinit.d/boot.d
ln -s ../greetd /etc/dinit.d/boot.d

#======================================
# Change hostname and set password and sudo
#--------------------------------------
echo "eweos-img" >/etc/hostname
adduser -D ewe
echo 'root:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe ALL=(ALL:ALL) NOPASSWD: ALL' >>/etc/sudoers

#======================================
# Initialize system users and groups
#--------------------------------------
catnest
adduser ewe video
adduser ewe seat
adduser greeter video
adduser greeter seat

#======================================
# Set greeter text
#--------------------------------------
sed -i 's/^command = .*$/command = "CMD"/g' /etc/greetd/config.toml
sed -i "s@CMD@tuigreet -t -r -g 'This image is unstable and for developers only\\\ndefault user/pass: ewe/ewe' --cmd bash@g" /etc/greetd/config.toml

#======================================
# Write fstab (Currently placeholder)
#--------------------------------------
touch /etc/fstab

#======================================
# Make unified kernel image
#--------------------------------------
if [[ $kiwi_profiles == *"diskimage"* ]]; then
  sed -i 's@root=.*@root=LABEL="EWE_ROOT"@' /etc/tinyramfs/config
  genefistub
  # KIWI searches for efi instead of EFI
  mkdir -p /boot/efi
  mv /boot/EFI /boot/efi/EFI
fi

#======================================
# Configure autologin
#--------------------------------------
if [[ $kiwi_profiles == *"squashfs"* ]]; then
cat <<EOF >>/etc/greetd/config.toml
[initial_session]
command = "bash -c 'cat /etc/motd && bash'"
user = "ewe"
EOF
fi

#======================================
# Testing: Enable global mimalloc
#--------------------------------------
echo "LD_PRELOAD=/usr/lib/libmimalloc.so" >> /etc/environment

#======================================
# Testing: Enable global lto
#--------------------------------------
echo LTOFLAGS="-flto=auto" >> /etc/makepkg.conf
sed -i 's@!lto@lto@g' /etc/makepkg.conf

#======================================
# Testing: Enable testing repo
#--------------------------------------
cat <<EOF >>/etc/pacman.conf
[options]
HoldPkg     = pacman musl busybox
Architecture = auto
Color
CheckSpace
ParallelDownloads = 8

[main]
SigLevel = Never
Server = http://os-repo.ewe.moe/eweos/main/os/$arch/

[testing]
SigLevel = Never
Server = http://os-repo.ewe.moe/eweos/testing/os/$arch/
EOF
