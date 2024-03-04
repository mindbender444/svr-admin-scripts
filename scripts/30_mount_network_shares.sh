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
    exit 1
fi

# Check if cifs-utils package is installed
if ! dpkg-query -W -f='${Status}' cifs-utils 2>/dev/null | grep -q "install ok installed"; then
    echo "cifs-utils package is not installed. It is required for mounting SMB shares."
    read -p "Do you want to install it? (Y/N): " install_choice
    if [[ "${install_choice,,}" == "y" ]]; then
        apt-get update && apt-get install -y cifs-utils
        echo "cifs-utils package installed."
    else
        echo "Exiting. cifs-utils package is required."
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

# Ask the user how many shares they want to mount
read -p "How many SMB shares do you want to mount? " share_count

for ((i=1; i<=share_count; i++)); do
    echo "Enter details for share $i:"
    read -p "SMB Share (e.g., //192.168.1.100/sharename): " smb_share
    read -p "Mount Point (e.g., /mnt/sharename): " mount_point

    # Create mount directory
    create_mount_directory "$mount_point"

    # Define fstab line
    fstab_line="${smb_share} ${mount_point} cifs uid=0,noserverino,credentials=${credentials_file},iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,vers=3.0 0 0"

    # Add fstab entry if it doesn't exist
    if ! grep -qF "$fstab_line" /etc/fstab; then
        echo "$fstab_line" >> /etc/fstab
        echo "Entry for $smb_share added to /etc/fstab."
    fi
done

# Mount all filesystems
if ! mount -a; then
    echo "Failed to mount shares. Check the fstab entries and credentials."
    exit 1
fi

echo "Shares should now be mounted."
