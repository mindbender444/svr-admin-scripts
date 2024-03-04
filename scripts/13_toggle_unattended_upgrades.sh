#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Function to disable unattended upgrades
disable_unattended_upgrades() {
    systemctl stop unattended-upgrades
    systemctl disable unattended-upgrades

    # Modify /etc/apt/apt.conf.d/10periodic
    sed -i 's/^APT::Periodic::Update-Package-Lists "1"/APT::Periodic::Update-Package-Lists "0"/' /etc/apt/apt.conf.d/10periodic
    sed -i 's/^APT::Periodic::Unattended-Upgrade "1"/APT::Periodic::Unattended-Upgrade "0"/' /etc/apt/apt.conf.d/10periodic

    # Modify /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i '/^Unattended-Upgrade::Mail/d' /etc/apt/apt.conf.d/50unattended-upgrades
    sed -i '/^Unattended-Upgrade::Remove-Unused-Dependencies/d' /etc/apt/apt.conf.d/50unattended-upgrades

    echo "Unattended upgrades have been disabled."
}

# Function to enable unattended upgrades
enable_unattended_upgrades() {
    systemctl start unattended-upgrades
    systemctl enable unattended-upgrades

    # Modify /etc/apt/apt.conf.d/10periodic
    sed -i 's/^APT::Periodic::Update-Package-Lists "0"/APT::Periodic::Update-Package-Lists "1"/' /etc/apt/apt.conf.d/10periodic
    sed -i 's/^APT::Periodic::Unattended-Upgrade "0"/APT::Periodic::Unattended-Upgrade "1"/' /etc/apt/apt.conf.d/10periodic

    # Modify /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Mail "your-email@example.com";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Allowed-Origins:: "origin=Debian,codename=${distro_codename},label=Debian-Security";' >> /etc/apt/apt.conf.d/50unattended-upgrades

    echo "Unattended upgrades have been enabled and started."
}

# Check the status of unattended-upgrades service
service_status=$(systemctl is-active unattended-upgrades)

if [ "$service_status" = "active" ]; then
    echo "The unattended-upgrades service is currently active."
    read -p "Do you want to stop and disable unattended-upgrades? [Y/n] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        disable_unattended_upgrades
    fi
else
    echo "The unattended-upgrades service is not active."
    read -p "Do you want to enable and start unattended-upgrades? [Y/n] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        enable_unattended_upgrades
    fi
fi

# Display final status of the service
systemctl status unattended-upgrades

