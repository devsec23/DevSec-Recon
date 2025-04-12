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
    spinner_pid=$!
}

# Function to stop the spinner when installation is complete
stop_spinner() {
    kill $spinner_pid  # Kill the background spinner process
    echo -e "\nTools installed successfully."
}

# Function to install all required tools
install_required_tools() {
    # Install subfinder
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    
    # Add other tools here if needed
    # go install github.com/projectdiscovery/httpx/cmd/httpx@latest
    # go install github.com/tomnomnom/assetfinder@latest
    # Add any additional tools you need to install
}

# Main installation process
install_tools_silently

# Install required tools
install_required_tools

# Stop spinner and confirm installation
stop_spinner

# Run actual tool (subfinder) with your domain (replace example.com with your domain)
echo "Running subfinder on example.com..."
subfinder -d example.com -o output.txt
