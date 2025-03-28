#!/bin/bash

samba_config_file="/etc/samba/smb.conf"
config_start="[opt]"

if [[ ! -f "$samba_config_file" ]]; then
    echo "Error: The Samba config file at $samba_config_file does not exist."
    exit 1
fi

awk -v start="$config_start" '
    $0 == start {remove=1; next} 
    remove && NF == 0 {remove=0; next} 
    !remove
' "$samba_config_file.bak" > "$samba_config_file"

echo "The dev-mode is disabled!"

systemctl restart smbd.service
echo "Samba has restarted."
