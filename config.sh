#!/bin/bash

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Generate initramfs
#--------------------------------------
cd / && ls usr/lib/modules/*/vmlinuz | /usr/share/libalpm/scripts/tinyramfs-gen

#======================================
# Enable virtio driver
#--------------------------------------
echo "virtio_net" >> /etc/modules
echo "virtio_gpu" >> /etc/modules
echo "virtio_input" >> /etc/modules

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
echo "eweos-img" > /etc/hostname
adduser -D ewe
echo 'root:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true
echo 'ewe ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers

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
