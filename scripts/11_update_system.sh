#!/bin/bash

clear
echo "Executing Update System"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    read -p "Press any key to continue..."
    exit 1
fi

# Confirmation prompt
read -p "Are you sure you want to update the system? This may take some time. (Y/N): " confirm
if [[ "${confirm,,}" != "y" ]]; then
    echo "System update cancelled."
    read -p "Press any key to continue..."
    exit 0
fi

# Update package lists
echo "Updating package lists..."
if ! apt update --quiet; then
    echo "Failed to update package lists."
    read -p "Press any key to continue..."
    exit 1
fi

# Upgrade installed packages
echo "Upgrading installed packages..."
if ! apt upgrade --quiet --assume-yes; then
    echo "Failed to upgrade packages."
    read -p "Press any key to continue..."
    exit 1
fi

# Cleaning up
echo "Cleaning up..."
apt autoremove --quiet --assume-yes
apt autoclean --quiet

echo "Ubuntu system update complete."

# Optional: Pause for user to see output
read -p "Press any key to continue..." -n1 -s
echo
