#!/bin/bash

# Colors
GREEN='\033[1;32m'
NC='\033[0m'

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    local msg="$1"
    echo -ne "${GREEN}[~] $msg... ${NC}"
    while ps a | awk '{print $1}' | grep -q "$pid"; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -ne "\b\b\b\b\b\b"
    echo -e "${GREEN}Done!${NC}"
}

# Banner
clear
echo -e "${GREEN}"
echo "██████╗ ███████╗████████╗███████╗██████╗ ███████╗███████╗"
echo "██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔════╝"
echo "██████╔╝███████╗   ██║   █████╗  ██████╔╝███████╗███████╗"
echo "██╔═══╝ ██╔════╝   ██║   ██╔══╝  ██╔═══╝ ╚════██╗╚════██╗"
echo "██║     ███████╗   ██║   ███████╗██║     ███████╔╝██████╔╝"
echo "╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═════╝ ╚═════╝"
echo -e "${NC}"

# Input
read -p "Enter domain name: " domain
mkdir -p tools results

# Install Tool Function
install_tool() {
    tool=$1
    install_cmd=$2
    if ! command -v "$tool" &> /dev/null; then
        (eval "$install_cmd") & spinner "Installing $tool"
    fi
}

# Tool Installation
install_tool "subfinder" "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && mv ~/go/bin/subfinder /usr/local/bin/"
install_tool "httpx" "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && mv ~/go/bin/httpx /usr/local/bin/"
install_tool "gau" "go install -v github.com/lc/gau/v2/cmd/gau@latest && mv ~/go/bin/gau /usr/local/bin/"

# Run subfinder (silent)
echo -e "${GREEN}[+] Running subfinder...${NC}"
subfinder -d "$domain" -silent > results/subdomains.txt

# Run httpx
echo -e "${GREEN}[+] Running httpx...${NC}"
httpx -o results/subdomains.txt -silent -status-code -title > results/httpx_output.txt

# Run gau
echo -e "${GREEN}[+] Running gau...${NC}"
gau "$domain" > results/gau_output.txt

# Done
echo -e "${GREEN}[✓] Recon completed. Results saved in 'results/' folder.${NC}"
