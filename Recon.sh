#!/bin/bash

# Function to simulate silent tool installation with a spinner
install_tools_silently() {
    echo -n "Installing tools silently... "
    spin="/-\|"
    while true; do
        for i in $spin; do
            echo -n "$i"  # Show spinner
            sleep 0.1
            echo -ne "\b"  # Backspace to overwrite previous character
        done
    done &
}

# Function to stop the spinner when installation is complete
stop_spinner() {
    kill $!  # Kill the background spinner process
    echo -e "\nTools installed successfully."
}

# Main installation process
install_tools_silently
# Simulate the installation time with sleep, replace with actual installation command
sleep 5  # Simulate installation time (you can replace this with the actual installation process)
stop_spinner

# Run actual tool installation or any command you want here
# For example:
# go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "Running subfinder on example.com..."
# Add your actual tool execution or command here, for example:
# subfinder -d example.com -o output.txt
