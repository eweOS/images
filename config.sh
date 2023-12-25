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
ln -s /usr/lib/dinit.d/system/udhcpc /etc/dinit.d/boot.d
if [[ $kiwi_profiles != *"tarball"* ]]; then
  ln -s /usr/lib/dinit.d/system/greetd /etc/dinit.d/boot.d
fi

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
if [[ $kiwi_profiles != *"tarball"* ]]; then
  adduser ewe video
  adduser ewe seat
  adduser greeter video
  adduser greeter seat
fi

#======================================
# Set greeter text
#--------------------------------------
if [[ $kiwi_profiles != *"tarball"* ]]; then
  sed -i 's/^command = .*$/command = "CMD"/g' /etc/greetd/config.toml
  sed -i "s@CMD@tuigreet -t -r -g 'This image is unstable and for developers only\\\ndefault user/pass: ewe/ewe' --cmd bash@g" /etc/greetd/config.toml
fi

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

