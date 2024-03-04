#!/bin/bash

# Clear the screen
clear
echo "Executing Install zsh For A User"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or using sudo."
    exit 1
fi

# Generate a list of users with UID greater than 1000
echo "Users on this system (UID >= 1000):"
user_list=($(awk -F':' '{ if ($3 > 999) print $1 }' /etc/passwd))

# Display the user list with numbers
for i in "${!user_list[@]}"; do
    echo "$((i+1)). ${user_list[$i]}"
done

# Prompt to choose a user from the list
echo "Please enter the number corresponding to the user:"
read -p "Enter number: " user_choice

# Validate input
if [[ ! $user_choice =~ ^[0-9]+$ ]] || [ $user_choice -lt 1 ] || [ $user_choice -gt ${#user_list[@]} ]; then
    echo "Invalid selection."
    exit 1
fi

# Get the selected username
username=${user_list[$((user_choice-1))]}

# Confirm installation
read -p "Do you want to install zsh for user $username? (Y/N): " confirm_install
if [[ "${confirm_install,,}" != "y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Check if zsh is installed, install if not
if ! command -v zsh &>/dev/null; then
    echo "Zsh is not installed. Installing Zsh..."
    apt-get update
    apt-get install zsh -y
fi

# Change the user's default shell to zsh if it's not already
if [ "$(getent passwd "$username" | cut -d':' -f7)" != "/usr/bin/zsh" ]; then
    chsh -s /usr/bin/zsh "$username"
    echo "zsh has been installed and set as the default shell for user $username."
else
    echo "zsh is already the default shell for user $username."
fi

# Pause the script
read -p "Press any key to continue..." -n1 -s
echo
