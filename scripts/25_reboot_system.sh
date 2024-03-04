#!/bin/bash

clear
echo "Executing Reboot Server"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    read -p "Press any key to continue..."
    exit 1
fi

read -p "Are you sure you want to reboot the server? (Y/N): " -n 1 -r
echo    # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting the server..."
    reboot
else
    echo "Reboot cancelled."
    read -p "Press any key to continue..."
    exit
fi

read -p "Press any key to continue..." -n1 -s
echo
