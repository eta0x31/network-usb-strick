#!/bin/bash

modprobe -r g_mass_storage
umount /mnt/usb_share
mount -a
rsync -av --delete --exclude='.*' /mnt/usb_share/ /mnt/network_share/
modprobe g_mass_storage file=/piusb.bin stall=0 ro=0 removable=1