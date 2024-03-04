#!/bin/bash

# Function to display menu
display_menu() {
    # Check if the script is run as root or with sudo privileges
    if [ "$(id -u)" != "0" ]; then
        echo "WARNING: Some scripts may not function properly without root or sudo privileges."
		echo
    fi

    echo "Select a script to run (or enter 'q' to quit):"
    local i=1
    for script in "${scripts[@]}"; do
        local display_script=$(basename "${script}" .sh) # Remove the .sh extension
        display_script=${display_script//_/ } # Replace underscores with spaces
        display_script=${display_script//-/ } # Replace hyphens with spaces

        # Remove leading numbers and adjust spaces if necessary
        display_script=$(echo "$display_script" | sed 's/^[0-9]*[[:space:]]*//')

        # Capitalize each word in the script name
        display_script=$(echo "$display_script" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

        echo "$i) $display_script"
        let i++
    done
}

# Main script execution
main() {
    # Get the current script name
    local current_script=$(basename "$0")

    # Define script directories
    local script_dirs=("scripts" ".scripts")

    # Initialize script arrays
    local numerically_sorted_scripts=()
    local other_scripts=()

    # Find all .sh files in the specified directories, excluding the current script
    for dir in "${script_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r -d '' file; do
                if [[ "$file" != *"$current_script" ]]; then
                    if [[ $(basename "$file") =~ ^[0-9] ]]; then
                        numerically_sorted_scripts+=("$file")
                    else
                        other_scripts+=("$file")
                    fi
                fi
            done < <(find "$dir" -type f -name "*.sh" -print0)
        fi
    done

    # Sort numerically sorted scripts
    IFS=$'\n' numerically_sorted_scripts=($(sort -n <<<"${numerically_sorted_scripts[*]}"))
    unset IFS

    # Combine the arrays, prioritizing numerically sorted scripts
    scripts=("${numerically_sorted_scripts[@]}" "${other_scripts[@]}")

    # Check if there are other scripts
    if [ ${#scripts[@]} -eq 0 ]; then
        echo "No bash scripts found in the 'scripts' or '.scripts' directories."
        exit 1
    fi
    
    clear
    # Loop to display the menu repeatedly
    while true; do
        # Display the menu
        display_menu

        # Get user input
        read -p "Enter your choice (number or 'q' to quit): " choice

        # Check for quit command
        if [[ "$choice" == "q" ]]; then
            clear
            break
        fi

        # Validate user input
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ $choice -le 0 ] || [ $choice -gt ${#scripts[@]} ]; then
            echo "Invalid selection. Please choose a valid number."
            continue
        fi

        # Run the selected script
        echo "Running ${scripts[$choice-1]}..."
        bash "${scripts[$choice-1]}"
        clear
    done
}

# Run the main function
main
