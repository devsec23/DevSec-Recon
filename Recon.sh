#!/bin/bash

# Display logo
echo -e "\033[1;32m
██████╗ ███████╗████████╗███████╗██████╗ ███████╗███████╗
██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔════╝
██████╔╝███████╗   ██║   █████╗  ██████╔╝███████╗███████╗
██╔═══╝ ██╔════╝   ██║   ██╔══╝  ██╔═══╝ ╚════██╗╚════██╗
██║     ███████╗   ██║   ███████╗██║     ███████╔╝██████╔╝
╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═════╝ ╚═════╝
\033[0m"

# Check if subfinder is installed
if ! command -v subfinder &> /dev/null
then
    echo "subfinder is not installed. Installing..."
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
fi

# Check if httpx is installed
if ! command -v httpx &> /dev/null
then
    echo "httpx is not installed. Installing..."
    go install github.com/projectdiscovery/httpx/cmd/httpx@latest
fi

# Check if gau is installed
if ! command -v gau &> /dev/null
then
    echo "gau is not installed. Installing..."
    go install github.com/lc/gau/v2/cmd/gau@latest
fi

# Create a directory for results if it doesn't exist
mkdir -p results

# Gather subdomains
echo "Running subfinder..."
subfinder -d example.com -o results/subdomains.txt

# Check HTTP endpoints with httpx
echo "Running httpx..."
httpx -l results/subdomains.txt -o results/httpx_output.txt

# Fetch URLs with gau
echo "Running gau..."
gau example.com -o results/gau_output.txt

# Summary
echo -e "\033[1;34m[INFO] Recon completed. Results saved in the 'results' directory.\033[0m"
