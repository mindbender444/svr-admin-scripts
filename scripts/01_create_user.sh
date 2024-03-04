#!/bin/bash

# Function to check if a user already exists
user_exists() {
    id "$1" &>/dev/null
}

# Function to pause the script
pause() {
    read -p "Press any key to continue..." -n1 -s
	echo
}

# Clear the screen and start the main script
clear
echo "User Creation Script"
echo "---------------------"

# Prompt for the new username
read -p "Enter the username: " username

# Check if the user already exists
if user_exists "$username"; then
    echo "User $username already exists."
    pause
    exit 1  # Exit with a non-zero status to indicate failure
fi

# Attempt to add the new user
if ! adduser "$username"; then
    echo "Failed to create user $username. Please check your permissions."
    pause
    exit 1
fi

# Option to add the new user to the sudo group
read -p "Do you want to add $username to the sudo group? (Y/N): " add_to_sudo
if [[ "${add_to_sudo,,}" == "y" ]]; then
    if usermod -aG sudo "$username"; then
        echo "$username has been added to the sudo group."
    else
        echo "Failed to add $username to the sudo group."
        # Consider handling this error more gracefully
    fi
fi

# Option to copy the .ssh directory
read -p "Do you want to copy the .ssh directory from /home/user to /home/$username? (Y/N): " copy_ssh
if [[ "${copy_ssh,,}" == "y" ]]; then
    if [ -d "/home/user/.ssh" ]; then
        cp -r /home/user/.ssh /home/$username/
        chown -R "$username:$username" /home/$username/.ssh
        chmod 700 /home/$username/.ssh
        chmod 600 /home/$username/.ssh/*
        echo "The .ssh directory has been copied and permissions have been set."
    else
        echo "The .ssh directory does not exist in /home/user."
    fi
fi

# Completion message
echo "User $username has been created successfully."
pause
