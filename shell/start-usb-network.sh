#!/bin/bash

modprobe -r g_mass_storage
modprobe g_ether
ip addr add 111.111.111.111/24 dev usb0
ip link set usb0 up