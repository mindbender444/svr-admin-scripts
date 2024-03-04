#!/bin/bash

clear
echo "Executing Delete a User"

echo "List of users on the system:"
awk -F':' '{ if ($3 >= 1000) print $1 }' /etc/passwd

read -p "Do you want to delete a user? (Y/n): " choice

case "$choice" in
    [Yy]|[Yy][Ee][Ss])
        read -p "Enter the username to delete: " username
        if [ "$SUDO_USER" = "$username" ]; then
            echo "Cannot delete the user who invoked sudo."
        elif id "$username" &>/dev/null; then
            read -p "Are you sure you want to delete $username? (Y/n): " confirm
            case "$confirm" in
                [Yy]|[Yy][Ee][Ss])
                    if userdel -r "$username"; then
                        echo "User $username has been deleted."
                    else
                        echo "Failed to delete user $username. Check your permissions."
                    fi
                    ;;
                *)
                    echo "User deletion canceled."
                    ;;
            esac
        else
            echo "User $username not found."
        fi
        ;;
    *)
        echo "No User Deleted."
        ;;
esac

read -p "Press any key to continue..." -n1 -s
