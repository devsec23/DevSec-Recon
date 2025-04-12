#!/bin/bash

# Show a fancy logo
clear
echo -e "\e[1;32m"
echo "   ____            ____       _____        ____  "
echo "  | __ )  ___  ___| __ ) ___ | ____|__  __| ___|"
echo "  |  _ \ / _ \/ __|  _ \ / _ \|  _| / _|/ _|  _|"
echo "  | |_) |  __/ (__| |_) | (_) | |__|  _|  __| |__"
echo "  |____/ \___|\___|____/ \___/|____|_|  \___|\___|"
echo -e "\e[0m"

# Function to show the progress bar
progress_bar() {
    local pid=$!
    local delay=0.1
    local spin='-\|/'
    local i=0
    echo -n ' '
    while ps -p $pid > /dev/null; do
        i=$(( (i+1) %4 ))
        echo -n "\r${spin:i:1}"
        sleep $delay
    done
    echo -n ' '
}

# Function to install tools quietly
install_tools() {
    echo "Installing tools silently..."
    
    # Install subfinder if not installed
    if ! command -v subfinder &>/dev/null; then
        go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest &>/dev/null &
        progress_bar $!
    fi

    # Install gau if not installed
    if ! command -v gau &>/dev/null; then
        go install github.com/lc/gau/v2/cmd/gau@latest &>/dev/null &
        progress_bar $!
    fi

    # Install httpx if not installed
    if ! command -v httpx &>/dev/null; then
        go install github.com/projectdiscovery/httpx/cmd/httpx@latest &>/dev/null &
        progress_bar $!
    fi
}

# Set a default target if none provided
TARGET=${1:-example.com}

# Run tools on a default domain
run_tools() {
    echo "Running subfinder on $TARGET..."
    subfinder -d $TARGET -o subdomains.txt &
    progress_bar $!

    echo "Running gau on $TARGET..."
    gau $TARGET > gau_results.txt &
    progress_bar $!

    echo "Running httpx on $TARGET..."
    httpx -l subdomains.txt -o httpx_results.txt &
    progress_bar $!

    echo "Recon completed. Results saved in 'subdomains.txt', 'gau_results.txt', and 'httpx_results.txt'."
}

# Install tools in silence
install_tools

# Run the tools
run_tools
