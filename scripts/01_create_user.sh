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
read -p "Do you want to copy the .ssh directory from your home directory to /home/$username? (Y/N): " copy_ssh
if [[ "${copy_ssh,,}" == "y" ]]; then
    # Use "$HOME" to refer to the current user's home directory
    if [ -d "$HOME/.ssh" ]; then
        # Copy the .ssh directory from the current user's home to the specified directory
        cp -r "$HOME/.ssh" "/home/$username/"
        # Set the owner of the copied .ssh directory to the specified user
        chown -R "$username:$username" "/home/$username/.ssh"
        # Set directory permissions
        chmod 700 "/home/$username/.ssh"
        # Set file permissions
        chmod 600 "/home/$username/.ssh/"*
        echo "The .ssh directory has been copied and permissions have been set."
    else
        echo "The .ssh directory does not exist in your home directory."
    fi
fi


# Completion message
echo "User $username has been created successfully."
pause
