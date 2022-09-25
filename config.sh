#!/bin/bash

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Copy kernel image
#--------------------------------------
cp /usr/lib/modules/*/vmlinuz /boot/vmlinuz

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

#======================================
# Change hostname and set password
#--------------------------------------
echo "eweos-img" > /etc/hostname
echo 'root:$1$ewe$gaySV0Ar7d0prQ/1fYOKu0' | chpasswd -e || true


