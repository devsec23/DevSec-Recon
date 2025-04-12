#!/bin/bash

# Define color for green text
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset to default)

# Function to install tools silently without showing the download process
install_tools_silently() {
    echo -e "${GREEN}Installing tools ...${NC}"
    
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
        echo -e "${GREEN}No domain provided. Exiting...${NC}"
        exit 1
    fi
    
    DOMAIN=$1
    echo -e "${GREEN}Running subfinder on $DOMAIN...${NC}"
    subfinder -d "$DOMAIN" -o subfinder_output.txt
}

run_gau() {
    if [ -z "$1" ]; then
        echo -e "${GREEN}No domain provided. Exiting...${NC}"
        exit 1
    fi
    
    DOMAIN=$1
    echo -e "${GREEN}Running gau on $DOMAIN...${NC}"
    gau "$DOMAIN" --o gau_output.txt
}

run_httpx() {
    if [ -z "$1" ]; then
        echo -e "${GREEN}No domain provided. Exiting...${NC}"
        exit 1
    fi

    DOMAIN=$1
    echo -e "${GREEN}Running httpx on $DOMAIN...${NC}"

    # دمج نتائج subfinder و gau في ملف واحد
    cat subfinder_output.txt gau_output.txt | sort -u > combined_output.txt

    # عرض عدد الروابط المدمجة
    echo -e "${GREEN}Number of URLs found: $(wc -l < combined_output.txt)${NC}"

    # تمرير الملف إلى httpx لفحص الروابط الحية
    httpx -l combined_output.txt -status-code -title -follow-redirects -o httpx_output.txt

    # عرض عدد الروابط الحية
    live_urls=$(grep -c "200" httpx_output.txt)
    echo -e "${GREEN}Number of live URLs: $live_urls${NC}"
}

# Main script execution
install_tools_silently  # Install tools silently
echo -e "${GREEN}Tools installed successfully.${NC}"

# Prompt user for domain input
echo -e "${GREEN}Please enter the domain to scan:${NC}"
read DOMAIN

# Run the tools with the user-provided domain
run_subfinder "$DOMAIN"
run_gau "$DOMAIN"
run_httpx "$DOMAIN"

echo -e "${GREEN}All tools executed successfully.${NC}"
