#!/bin/bash

# Clear the screen
clear

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Executing Install Oh My Zsh"

# Function to ensure a package is installed
ensure_package_installed() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 is not installed. Installing $1..."
        apt-get update
        apt-get install "$1" -y
    fi
}

# Install Zsh and Git if they are not installed
ensure_package_installed zsh
ensure_package_installed git

# List users with UID greater than 1000
echo "Select a user from the following list:"
user_list=($(awk -F: '($3>=1000)&&($1!="nobody"){print $1}' /etc/passwd))
for i in "${!user_list[@]}"; do
    echo "$((i+1))) ${user_list[$i]}"
done

# User selection
read -p "Enter the number corresponding to the user: " user_choice
if ! [[ "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 1 ] || [ "$user_choice" -gt "${#user_list[@]}" ]; then
    echo "Invalid selection."
    exit 1
fi
username=${user_list[$((user_choice-1))]}

# Rest of the script
user_home=$(getent passwd "$username" | cut -d: -f6)

# Check if the user exists and get home directory
if [ -d "$user_home" ]; then
    # Check if Oh My Zsh is already installed
    if [ -d "$user_home/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed for user $username."
        read -p "Press any key to continue..."
        exit 0
    fi

    # Confirm installation
    read -p "Do you want to install Oh My Zsh for user $username? (Y/N): " choice
    if [[ "${choice,,}" == "y" ]]; then
        # Run the Oh My Zsh installation command
        echo "Installing Oh My Zsh for user $username..."
        if ! su -c "sh -c \"\$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)\"" - "$username"; then
            echo "Failed to install Oh My Zsh for user $username."
            read -p "Press any key to continue..."
            exit 1
        fi
        echo "Oh My Zsh installed successfully for user $username."

        # Change the ZSH_THEME to 'gentoo' if requested
        read -p "Do you want to change the ZSH_THEME to 'gentoo' for user $username? (Y/N): " theme_choice
        if [[ "${theme_choice,,}" == "y" ]]; then
            su -c "sed -i 's/ZSH_THEME=.*/ZSH_THEME=\"gentoo\"/' $user_home/.zshrc" - "$username"
            echo "ZSH_THEME changed to 'gentoo' for user $username."
        fi

        # Install plugins if requested
        read -p "Do you want to install helpful plugins for user $username? (Y/N): " plugins_choice
        if [[ "${plugins_choice,,}" == "y" ]]; then
            zsh_custom_dir="\${ZSH_CUSTOM:-$user_home/.oh-my-zsh/custom}"
            su -c "mkdir -p $zsh_custom_dir/plugins" - "$username"

            # Declare an array of plugins
            declare -a plugins=("zsh-autosuggestions" "zsh-history-substring-search" "zsh-syntax-highlighting")

            for plugin in "${plugins[@]}"; do
                plugin_dir="$zsh_custom_dir/plugins/$plugin"
                if [ ! -d "$plugin_dir" ]; then
                    git_clone_command="git clone https://github.com/zsh-users/$plugin.git $plugin_dir"
                    su -c "$git_clone_command" - "$username"
                fi
                # Add plugin to .zshrc if not already present
                su -c "grep -q '^plugins=(.*\<$plugin\>' $user_home/.zshrc || sed -i '/^plugins=/s/)/ $plugin)/' $user_home/.zshrc" - "$username"
            done
            echo "Helpful plugins installed and added to the .zshrc file for user $username."
        fi
    fi
else
    echo "User $username does not exist or home directory not found."
fi

# Pause the script
read -p "Press any key to continue..." -n1 -s
echo