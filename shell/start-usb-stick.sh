#!/bin/bash

modprobe -r g_ether
systemctl daemon-reload
mount -a
modprobe g_mass_storage file=/piusb.bin stall=0 ro=0 removable=1