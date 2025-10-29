#!/usr/bin/env bash
#=====================================================================
# Recon Tool – Subfinder + Gau + Httpx
# Author: DevSec Zone
# Version: 2.1 (English + Progress Bar + ETA)
#=====================================================================

set -euo pipefail

# ---------- Colors ----------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- Messages ----------
msg() {
    local color=$1; shift
    case $1 in
        "install")   echo -e "${color}Installing tools...${NC}" ;;
        "done")      echo -e "${color}Installation completed${NC}" ;;
        "domain")    echo -e "${color}Enter domain to scan:${NC}" ;;
        "subfinder") echo -e "${color}Running subfinder on $2...${NC}" ;;
        "gau")       echo -e "${color}Running gau on $2...${NC}" ;;
        "httpx")     echo -e "${color}Probing live URLs...${NC}" ;;
        "live")      echo -e "${color}Live URLs: $2${NC}" ;;
        "total")     echo -e "${color}Total merged URLs: $2${NC}" ;;
        "report")    echo -e "${color}Report saved to $2${NC}" ;;
        "error")     echo -e "${RED}ERROR: $2${NC}" ;;
        *)           echo -e "${color}$1${NC}" ;;
    esac
}

# ---------- Install Go if missing ----------
install_go() {
    if ! command -v go &>/dev/null; then
        msg "$YELLOW" "install"
        pkg install -y golang &>/dev/null
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.bashrc"
        export PATH=$PATH:$HOME/go/bin
    fi
}

# ---------- Check if tool is installed ----------
tool_installed() {
    local bin=$1
    [[ -f "$HOME/go/bin/$bin" ]] || return 1
}

# ---------- Progress Bar with ETA ----------
install_with_progress() {
    local repo=$1 bin=$2
    if tool_installed "$bin"; then
        return 0
    fi

    echo -e "${YELLOW}Installing $bin...${NC}"

    # Start installation in background
    go install "$repo@latest" &>/dev/null &
    local pid=$!
    local start_time=$(date +%s)
    local elapsed=0
    local estimated_total=90  # average install time in seconds (adjust if needed)

    while kill -0 $pid 2>/dev/null; do
        elapsed=$(( $(date +%s) - start_time ))
        if (( elapsed > 0 )); then
            local percent=$(( (elapsed * 100) / estimated_total ))
            (( percent > 100 )) && percent=100
            local remaining=$(( estimated_total - elapsed ))
            (( remaining < 0 )) && remaining=0

            # Progress bar
            local filled=$(( percent / 2 ))
            local empty=$(( 50 - filled ))
            printf "\r[${BLUE}%-${filled}s%-${empty}s${NC}] %3d%% | ETA: %ds" \
                "$(printf '%*s' "$filled" '' | tr ' ' '#')" \
                "$(printf '%*s' "$empty" '' | tr ' ' '-')" \
                "$percent" "$remaining"
        fi
        sleep 1
    done
    wait $pid 2>/dev/null || true
    printf "\n"
}

install_tools() {
    install_go
    install_with_progress "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "subfinder"
    install_with_progress "github.com/lc/gau/v2/cmd/gau" "gau"
    install_with_progress "github.com/projectdiscovery/httpx/cmd/httpx" "httpx"
    msg "$GREEN" "done"
}

# ---------- Parse arguments ----------
DOMAIN=""

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 [-d <domain>]"
                echo "Example: $0 -d example.com"
                exit 0
                ;;
            *)
                msg "$RED" "error" "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

# ---------- Setup workspace ----------
setup_workspace() {
    local d=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')
    WORKDIR="$HOME/recon-$d"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
}

# ---------- Run tools ----------
run_subfinder() {
    msg "$GREEN" "subfinder" "$DOMAIN"
    subfinder -d "$DOMAIN" -silent -o subfinder.txt
}

run_gau() {
    msg "$GREEN" "gau" "$DOMAIN"
    gau "$DOMAIN" --silent > gau.txt
}

merge_urls() {
    cat subfinder.txt gau.txt 2>/dev/null | sort -u > combined.txt
    local total=$(wc -l < combined.txt)
    msg "$YELLOW" "total" "$total"
}

run_httpx() {
    msg "$GREEN" "httpx" ""
    httpx -list combined.txt -silent -status-code -title -follow-redirects -o httpx.txt
    local live=$(grep -c "200" httpx.txt || echo 0)
    msg "$GREEN" "live" "$live"
}

generate_report() {
    local report="report.txt"
    {
        echo "=== Recon Report for $DOMAIN ==="
        echo "Date: $(date)"
        echo
        echo "Subdomains  : $(wc -l < subfinder.txt 2>/dev/null || echo 0)   (subfinder.txt)"
        echo "URLs (gau)  : $(wc -l < gau.txt 2>/dev/null || echo 0)       (gau.txt)"
        echo "Merged URLs : $(wc -l < combined.txt)  (combined.txt)"
        echo "Live URLs   : $(grep -c "200" httpx.txt || echo 0) (httpx.txt)"
        echo
        echo "=== First 10 Live URLs ==="
        grep "200" httpx.txt | head -10
    } > "$report"
    msg "$GREEN" "report" "$WORKDIR/$report"
}

# ---------- Main ----------
main() {
    parse_args "$@"

    if [[ -z "$DOMAIN" ]]; then
        msg "$YELLOW" "domain"
        read -r DOMAIN
    fi

    [[ -z "$DOMAIN" ]] && { msg "$RED" "error" "No domain provided"; exit 1; }

    install_tools
    setup_workspace

    run_subfinder
    run_gau
    merge_urls
    run_httpx
    generate_report

    echo -e "${GREEN}All tools executed successfully.${NC}"
}

main "$@"