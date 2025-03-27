#!/bin/bash

modprobe -r g_mass_storage
rsync -av --delete --exclude='.*' /mnt/network_share/ /mnt/usb_share/
sync
modprobe g_mass_storage file=/piusb.bin stall=0 ro=0 removable=1