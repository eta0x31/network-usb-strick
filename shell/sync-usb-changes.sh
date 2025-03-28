#!/bin/bash

modprobe -r g_mass_storage
umount /mnt/primary-usb-mount
mount -a
rsync -av --delete --exclude='.*' /mnt/primary-usb-mount /mnt/network-share/
modprobe g_mass_storage file=/primary-usb-container.bin stall=0 ro=0 removable=1