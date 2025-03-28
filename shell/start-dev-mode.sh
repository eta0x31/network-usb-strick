#!/bin/bash

samba_config_file="/etc/samba/smb.conf"
samba_config_block="[opt]
browseable = yes
path = /opt
guest ok = yes
read only = no
create mask = 0777
directory mask = 0777
force user = root
force group = root"

if [[ ! -f "$samba_config_file" ]]; then
    echo "Error: The samba config file $samba_config_file does not exist."
    exit 1
fi

# Check if the block already exists in the file
if ! grep -Fxq "$(echo "$samba_config_block" | head -n 1)" "$samba_config_file"; then
    echo -e "\n$samba_config_block" >> "$samba_config_file"
    echo "Configuration block added to $samba_config_file"
    systemctl restart smbd.service
    echo "The dev-mode is now enabled!"
else
    echo "The dev-mode was already enabled!"
fi