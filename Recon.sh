#!/bin/bash

# Function to install tools silently without showing the download process
install_tools_silently() {
    echo "Installing tools silently..."
    
    # Install subfinder silently, no output shown to the user
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null

    # Add any other tools you need to install here (in a similar silent manner)
    # go install github.com/projectdiscovery/httpx/cmd/httpx@latest &>/dev/null
    # go install github.com/tomnomnom/assetfinder@latest &>/dev/null
}

# Function to run the tool (subfinder) after installing it
run_subfinder() {
    if [ -z "$1" ]; then
        echo "No domain provided. Exiting..."
        exit 1
    fi
    
    DOMAIN=$1
    echo "Running subfinder on $DOMAIN..."
    subfinder -d "$DOMAIN" -o output.txt
}

# Main script execution
install_tools_silently  # Install tools silently
echo "Tools installed successfully."

# Prompt user for domain input
echo "Please enter the domain to scan:"
read DOMAIN

# Run the tool with the user-provided domain
run_subfinder "$DOMAIN"
