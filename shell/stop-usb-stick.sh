#!/bin/bash

modprobe -r g_mass_storage
umount /mnt/primary-usb-mount
umount /mnt/secondary-usb-mount