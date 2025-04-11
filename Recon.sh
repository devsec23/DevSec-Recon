#!/bin/bash

echo -e "\033[1;32m
██████╗ ███████╗████████╗███████╗██████╗ ███████╗███████╗
██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔════╝
██████╔╝███████╗   ██║   █████╗  ██████╔╝███████╗███████╗
██╔═══╝ ██╔════╝   ██║   ██╔══╝  ██╔═══╝ ╚════██╗╚════██╗
██║     ███████╗   ██║   ███████╗██║     ███████╔╝██████╔╝
╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═════╝ ╚═════╝
\033[0m"

read -p "Enter domain name: " domain
mkdir -p results

install_tool() {
    tool=$1
    repo=$2
    if ! command -v "$tool" &> /dev/null; then
        echo "[!] $tool not found, installing..."
        go install "$repo@latest"
        export PATH=$PATH:$(go env GOPATH)/bin
    fi
}

install_tool subfinder github.com/projectdiscovery/subfinder/v2/cmd/subfinder
install_tool httpx github.com/projectdiscovery/httpx/cmd/httpx
install_tool gau github.com/lc/gau/v2/cmd/gau

echo -e "\n[+] Running subfinder..."
subfinder -d "$domain" -silent -o results/subdomains.txt

if [[ ! -s results/subdomains.txt ]]; then
    echo "[-] No subdomains found."
    exit 1
fi

echo -e "\n[+] Running httpx..."
httpx -list results/subdomains.txt -silent -o results/httpx_output.txt

echo -e "\n[+] Running gau..."
gau "$domain" --o results/gau_output.txt

echo -e "\n\033[1;34m[✓] Recon completed. Results saved in the 'results' folder.\033[0m"
