#!/bin/bash

# Function to prompt for confirmation
confirm() {
    while true; do
        read -rp "$1 [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to pause the script
pause() {
    read -p "Press any key to continue..." -n1 -s
	echo
}

# Updating and installing prerequisites
echo "Updating package information and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings

# Adding Docker's GPG key
if confirm "Do you want to add Docker's official GPG key?"; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
else
    echo "Skipping addition of Docker's GPG key."
fi

# Adding the Docker repository
if confirm "Do you want to add the Docker repository to your APT sources?"; then
    CODENAME=$(lsb_release -cs)
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $CODENAME stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
else
    echo "Skipping addition of Docker repository."
fi

# Installing Docker packages
if confirm "Do you want to install Docker Engine, CLI, and other components?"; then
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "Docker components installed."
else
    echo "Skipping Docker components installation."
fi

# Verifying the installation
if confirm "Do you want to verify the Docker Engine installation by running the hello-world image?"; then
    sudo docker run hello-world
	pause	
else
    echo "Skipping verification."
fi

echo "Docker installation script completed."
