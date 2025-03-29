#!/bin/bash

modprobe -r g_mass_storage
rsync -av --delete --exclude='.*' /mnt/network-share/ /mnt/primary-usb-mount
sync
modprobe g_mass_storage file=/primary-usb-container.bin stall=0 ro=0 removable=1