#!/bin/bash

# Function to handle creating mount directories
create_mount_directory() {
    local mount_point=$1
    if [ ! -d "$mount_point" ]; then
        mkdir -p "$mount_point"
        echo "Mount directory created at $mount_point."
    else
        echo "Mount directory $mount_point already exists."
    fi
}

clear
echo "Executing Mount Network Shares"

# Ensure script is run as root or with sudo
if [[ $(id -u) -ne 0 ]]; then
    echo "This script requires root privileges. Please run with sudo."
    read -p "Press any key to continue..."
    exit 1
fi

# Check if cifs-utils package is installed
if ! dpkg-query -W -f='${Status}' cifs-utils 2>/dev/null | grep -q "install ok installed"; then
    read -p "cifs-utils package is not installed. Do you want to install it? (Y/N): " install_choice
    if [[ "${install_choice,,}" == "y" ]]; then
        apt-get update
        if ! apt-get install -y cifs-utils; then
            echo "Failed to install cifs-utils. Check your internet connection or package repository settings."
            read -p "Press any key to continue..."
            exit 1
        fi
        echo "cifs-utils package installed."
    else
        echo "cifs-utils package is required for mounting SMB shares. Exiting."
        read -p "Press any key to continue..."
        exit 1
    fi
fi

# Prompt for SMB credentials
echo "Create credentials file."
read -p "Enter SMB username: " smb_username
read -sp "Enter SMB password: " smb_password
echo

# Define and secure the credentials file
credentials_file="/usr/local/share/.smbcredentials"
echo "username=${smb_username}" > "${credentials_file}"
echo "password=${smb_password}" >> "${credentials_file}"
chmod 600 "${credentials_file}"
chown root:root "${credentials_file}"
echo "SMB credentials have been written to ${credentials_file}"

# Define SMB shares and mount points
smb_share_1="//192.168.1.27/iR_datadir"
mount_point_1="/media/iR_datadir"
smb_share_2="//192.168.1.21/h4_datadir"
mount_point_2="/media/h4_datadir"

# Function to create a mount directory
create_mount_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Mount directory $1 created."
    fi
}

# Create mount directories
create_mount_directory "$mount_point_1"
create_mount_directory "$mount_point_2"

# Define fstab lines
fstab_line_1="${smb_share_1} ${mount_point_1} cifs uid=0,noserverino,credentials=${credentials_file},iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,vers=3.0 0 0"
fstab_line_2="${smb_share_2} ${mount_point_2} cifs uid=0,noserverino,credentials=${credentials_file},iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,vers=3.0 0 0"

# Add fstab entries if they don't exist
if ! grep -qF "$fstab_line_1" /etc/fstab; then
    echo "$fstab_line_1" >> /etc/fstab
    echo "First entry added to /etc/fstab."
fi
if ! grep -qF "$fstab_line_2" /etc/fstab; then
    echo "$fstab_line_2" >> /etc/fstab
    echo "Second entry added to /etc/fstab."
fi

# Mount all filesystems
if ! mount -a; then
    echo "Failed to mount shares. Check the fstab entries and credentials."
    read -p "Press any key to continue..."
    exit 1
fi

echo "Shares should now be mounted under /media."
read -p "Press any key to continue..." -n1 -s
