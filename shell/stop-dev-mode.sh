#!/bin/bash

samba_config_file="/etc/samba/smb.conf"

if [[ ! -f "$samba_config_file" ]]; then
    echo "Error: The samba config at $samba_config_file dose not exits."
    exit 1
fi

sed -i '/^\[opt\]/,/^$/d' "$samba_config_file"

echo "The dev-mode is disabled!"

systemctl restart smbd.service
echo "Samba has restarted."