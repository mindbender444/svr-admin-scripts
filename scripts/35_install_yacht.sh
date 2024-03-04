#!/bin/bash

clear
echo "Executing Install Yacht"

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root."
    read -p "Press any key to continue..."
    exit 1
fi

# Check if Docker is installed and running
if ! command -v docker &>/dev/null || ! (systemctl is-active --quiet docker); then
    echo "Docker is not installed or not running. Please install and start Docker first."
    read -p "Press any key to continue..."
    exit 1
fi

# Ask the user if they want to install and enable Yacht
read -p "Do you want to install and enable Yacht? (Y/N): " choice

if [[ "${choice,,}" == "y" ]]; then
    # Create a Docker volume and run the Yacht container
    if docker volume create yacht && \
       docker run -d --restart=unless-stopped -p 8000:8000 -v /var/run/docker.sock:/var/run/docker.sock -v yacht:/config selfhostedpro/yacht; then
        echo "Yacht installed."
        echo "Access Yacht at http://<your-server-ip>:8000"
        echo "Default credentials:"
        echo "User: admin@yacht.local"
        echo "Pass: pass"
    else
        echo "Failed to install Yacht."
        read -p "Press any key to continue..."
        exit 2
    fi
elif [[ "${choice,,}" == "n" ]]; then
    echo "Yacht not installed."
else
    echo "Invalid choice. Please enter Y or N."
    read -p "Press any key to continue..."
    exit 3
fi

# Optional: Pause for user to see the message
read -p "Press any key to continue..." -n1 -s
