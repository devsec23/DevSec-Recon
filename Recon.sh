#!/bin/bash

# Function to install tools silently without showing the download process
install_tools_silently() {
    echo "Installing tools silently..."
    
    # Install subfinder silently
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null
    
    # Install gau silently
    go install github.com/lc/gau/v2/cmd/gau@latest &>/dev/null

    # Install httpx silently
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest &>/dev/null
}

# Function to run the tools (subfinder, gau, httpx) after installing them
run_subfinder() {
    if [ -z "$1" ]; then
        echo "No domain provided. Exiting..."
        exit 1
    fi
    
    DOMAIN=$1
    echo "Running subfinder on $DOMAIN..."
    subfinder -d "$DOMAIN" -o subfinder_output.txt
}

run_gau() {
    if [ -z "$1" ]; then
        echo "No domain provided. Exiting..."
        exit 1
    fi
    
    DOMAIN=$1
    echo "Running gau on $DOMAIN..."
    gau "$DOMAIN" -o gau_output.txt
}

run_httpx() {
    if [ -z "$1" ]; then
        echo "No domain provided. Exiting..."
        exit 1
    fi
    
    DOMAIN=$1
    echo "Running httpx on $DOMAIN..."
    httpx -l "$DOMAIN" -o httpx_output.txt
}

# Main script execution
install_tools_silently  # Install tools silently
echo "Tools installed successfully."

# Prompt user for domain input
echo "Please enter the domain to scan:"
read DOMAIN

# Run the tools with the user-provided domain
run_subfinder "$DOMAIN"
run_gau "$DOMAIN"
run_httpx "$DOMAIN"

echo "All tools executed successfully."
