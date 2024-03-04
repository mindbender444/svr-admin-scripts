#!/bin/bash

clear
echo "Executing Change Hostname"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    read -p "Press any key to continue..."
    exit 1
fi

read -p "Do you want to change the hostname? (Y/N): " response

if [[ "${response,,}" == "y" ]]; then
    read -p "Enter the new hostname: " new_hostname

    # Validate the new hostname
    if [[ ! "$new_hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,62}$ ]]; then
        echo "Invalid hostname. Please enter a valid hostname."
        read -p "Press any key to continue..."
        exit 1
    fi

    # Attempt to change the hostname
    if hostnamectl set-hostname "$new_hostname"; then
        echo "Hostname changed to $new_hostname"
        echo "Please reboot the system for the change to take full effect."
    else
        echo "Failed to change hostname."
        exit 1
    fi
else
    echo "Hostname not changed."
fi

read -p "Press any key to continue..." -n1 -s
echo
