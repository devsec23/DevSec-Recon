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
    local total=$1
    local current=0
    while [ $current -le $total ]; do
        local progress=$((current * 100 / total))
        printf "\r[%-50s] %d%%" "$(printf '#%.0s' $(seq 1 $((progress / 2))))" "$progress"
        sleep 0.1
        ((current++))
    done
    echo
}

# Check if the required tools are installed
install_tool() {
    tool=$1
    if ! command -v $tool &> /dev/null
    then
        echo "$tool not found, installing..."
        progress_bar 20
        if [[ "$tool" == "subfinder" ]]; then
            go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        elif [[ "$tool" == "gau" ]]; then
            go install github.com/lc/gau/v2/cmd/gau@latest
        elif [[ "$tool" == "httpx" ]]; then
            go install github.com/projectdiscovery/httpx/cmd/httpx@latest
        fi
    else
        echo "$tool is already installed"
    fi
}

# Install necessary tools
echo "Installing tools..."
install_tool "subfinder"
install_tool "gau"
install_tool "httpx"

# Run the tools
echo "Running subfinder..."
progress_bar 50
subfinder -d example.com -o subdomains.txt
echo "Running gau..."
progress_bar 50
gau example.com > gau_results.txt
echo "Running httpx..."
progress_bar 50
httpx -l subdomains.txt -o httpx_results.txt

# Show completion message
echo "Recon completed. Results saved in 'subdomains.txt', 'gau_results.txt', and 'httpx_results.txt'."
