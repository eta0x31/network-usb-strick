#!/bin/bash

# ---------------------------------------------------------------------------------------------------
USB_FAT_TYPE=16
USB_SIZE_MB=2048
# ---------------------------------------------------------------------------------------------------

# Install all the necessaries apt modules
install_apt_modules() {
    apt update -y
    apt upgrade -y
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
    apt install samba winbind -y
    apt install dnsmasq -y
    apt install git -y
    # apt install build-essential -y
    # apt install python3 -y
    # apt install make -y
    # apt install gcc -y
    # apt install g++ -y
    # apt install node-gyp -y
    apt install nodejs -y

    echo "Verifying Node.js and npm installation..."
    node -v
    npm -v

    echo "Installing PM2 globally..."
    npm install -g pm2

    echo "Setting up PM2 to start on boot..."
    pm2 startup systemd -u pi --hp /home/pi

    echo "Installation complete! 🎉"
    echo "Node.js version: $(node -v)"
    echo "npm version: $(npm -v)"
    echo "PM2 version: $(pm2 -v)"
}

# ---------------------------------------------------------------------------------------------------

# Clean up some apt modules to make more space to support bigger usb partitions
clean_up_apt_modules() {
    apt-get remove --purge libreoffice* -y
    apt-get purge wolfram-engine -y
    apt-get clean
    apt-get autoremove -y
}

# ---------------------------------------------------------------------------------------------------

# Add the dwc2 to the boot config
update_boot_config_file() {
    local file="/boot/firmware/config.txt"
    local setting="dtoverlay=dwc2"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: The file $file does not exist."
        exit 1
    fi
    
    # Read the last line of the file
    local last_line=$(tail -n 1 "$file")
    
    if [[ "$last_line" != "$setting" ]]; then
        echo "$setting" >> "$file"
        echo "Setting appended: $setting in $file"
    else
        echo "Setting already present as last line: $setting in $file"
    fi
}

# ---------------------------------------------------------------------------------------------------

# Add the dwc2 to the kernel modules to load at boot time
update_modules_file() {
    local file="/etc/modules"
    local setting="dwc2"
    
    if [[ ! -f "$file" ]]; then
        echo "Error: The file $file does not exist."
        exit 1
    fi
    
    if ! grep -q "^$setting" "$file"; then
        echo "$setting" >> "$file"
        echo "Module added: $setting in $file"
    else
        echo "Module already present: $setting in $file"
    fi
}

# ---------------------------------------------------------------------------------------------------

# Create the usb container
create_usb_container() {
    local file="/piusb.bin"

    if [[ ! -f "$file" ]]; then
        echo "Start creating the usb container file in $file with a size of $USB_SIZE_MB MB and with a FAT-$USB_FAT_TYPE file system."
        dd bs=1M if=/dev/zero of=/piusb.bin count=$USB_SIZE_MB status=progress
        chmod 666 /piusb.bin
        mkdosfs /piusb.bin -F $USB_FAT_TYPE -I
        echo "The usb container file $file is created."
    else
        echo "The usb container file $file already exist."
    fi
}

# ---------------------------------------------------------------------------------------------------

# Create the usb container mount
create_usb_container_mount() {
    local mount_folder="/mnt/usb_share"
    local file="/etc/fstab"
    local setting="/piusb.bin /mnt/usb_share vfat users,rw,umask=000 0 2"

    if [[ ! -d "$mount_folder" ]]; then
        mkdir $mount_folder
        chmod 777 $mount_folder
        echo "Mount folder created in $mount_folder"
    else
        echo "The mount folder in $mount_folder already exists."
    fi

    if [[ ! -f "$file" ]]; then
        echo "Error: The file $file does not exist."
        exit 1
    fi
    
    if ! grep -q "^$setting" "$file"; then
        echo "$setting" >> "$file"
        systemctl daemon-reload
        mount -a
        echo "Fstab setting added: $setting in $file"
    else
        echo "Fstab setting already present: $setting in $file"
    fi
}

# ---------------------------------------------------------------------------------------------------

# Create the shared samba folder mount 
create_samba_mount() {
    local mount_folder="/mnt/network_share"
    local samba_config_file="/etc/samba/smb.conf"
    local samba_config_block="[usb]
    browseable = yes
    path = $mount_folder
    guest ok = yes
    read only = no
    create mask = 777"

    if [[ ! -d "$mount_folder" ]]; then
        mkdir $mount_folder
        chmod 777 $mount_folder
        echo "Samba mount folder created in $mount_folder"
    else
        echo "The samba mount folder in $mount_folder already exists."
    fi

    if [[ ! -f "$samba_config_file" ]]; then
        echo "Error: The samba config file $samba_config_file does not exist."
        exit 1
    fi
    
    # Check if the block already exists in the file
    if ! grep -Fxq "$(echo "$samba_config_block" | head -n 1)" "$samba_config_file"; then
        echo -e "\n$samba_config_block" >> "$samba_config_file"
        echo "Configuration block added to $samba_config_file"
        systemctl restart smbd.service
        echo "Restart samba service."
    else
        echo "Configuration block already present in $samba_config_file"
    fi
}

# ---------------------------------------------------------------------------------------------------

# Create the static usb network interface 
create_static_usb_network_interface() {
    local interface_file="/etc/systemd/network/usb0.network"
    local interface_block="
    [Match]
    Name=usb0

    [Network]
    Address=111.111.111.111/24
    DHCPServer=yes"

    if [[ ! -f "$interface_file" ]]; then
        touch $interface_file
        echo "The usb0 network config was created"
    else
        echo "The usb0 network config already exists."
    fi

    if ! grep -Fxq "$(echo "$interface_block" | head -n 1)" "$interface_file"; then
        echo -e "\n$interface_block" >> "$interface_file"
        echo "Configuration block added to $interface_file"
        systemctl enable systemd-networkd
        systemctl restart systemd-networkd
        echo "Restart networkd service."
    else
        echo "Configuration block already present in $interface_file"
    fi
}

# ---------------------------------------------------------------------------------------------------

# Create the dnsmasq config for the local dns server
create_dnsmasq_config() {
    local dnsmasq_file="/etc/dnsmasq.d/usb0.conf"
    local dnsmasq_block="
    interface=usb0
    dhcp-range=111.111.111.10,111.111.111.100,12h"

    if [[ ! -f "$dnsmasq_file" ]]; then
        touch $dnsmasq_file
        echo "The dnsmasq config was created"
    else
        echo "The dnsmasq config already exists."
    fi

    if ! grep -Fxq "$(echo "$dnsmasq_block" | head -n 1)" "$dnsmasq_file"; then
        echo -e "\n$dnsmasq_block" >> "$dnsmasq_file"
        echo "Configuration block added to $dnsmasq_file"
        systemctl restart dnsmasq
        systemctl enable dnsmasq
        echo "Restart networkd service."
    else
        echo "Configuration block already present in $dnsmasq_file"
    fi
}

# ---------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------

# Stages execution
install_apt_modules
clean_up_apt_modules
update_boot_config_file
update_modules_file
create_usb_container
create_usb_container_mount
create_samba_mount
create_static_usb_network_interface
create_dnsmasq_config