#!/usr/bin/env bash
#=====================================================================
# Recon Tool – Subfinder + Gau + Httpx
# Author: DevSec Zone
# Version: 3.1 (FIXED PATH + Auto Reload + Progress + ETA)
#=====================================================================

set -euo pipefail

# ---------- Colors ----------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------- Messages ----------
msg() {
    local color=$1; shift
    case $1 in
        "check")     echo -e "${CYAN}[CHECK] $2${NC}" ;;
        "missing")   echo -e "${YELLOW}[MISSING] $2${NC}" ;;
        "install")   echo -e "${YELLOW}[INSTALL] $2...${NC}" ;;
        "done")      echo -e "${GREEN}[DONE] $2${NC}" ;;
        "skip")      echo -e "${BLUE}[SKIP] $2${NC}" ;;
        "domain")    echo -e "${CYAN}Enter domain to scan:${NC}" ;;
        "subfinder") echo -e "${GREEN}Running subfinder on $2...${NC}" ;;
        "gau")       echo -e "${GREEN}Running gau on $2...${NC}" ;;
        "merge")     echo -e "${YELLOW}Merging results...${NC}" ;;
        "httpx")     echo -e "${GREEN}Probing live URLs...${NC}" ;;
        "live")      echo -e "${GREEN}Live URLs: $2${NC}" ;;
        "total")     echo -e "${YELLOW}Total merged URLs: $2${NC}" ;;
        "report")    echo -e "${GREEN}Report → $2${NC}" ;;
        "error")     echo -e "${RED}ERROR: $2${NC}" ;;
        *)           echo -e "${color}$1${NC}" ;;
    esac
}

#=====================================================================
# 1. AUTO RELOAD PATH (FIX)
#=====================================================================
export PATH="$PATH:$HOME/go/bin"
[[ -f "$HOME/.bashrc" ]] && grep -q "go/bin" "$HOME/.bashrc" || echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.bashrc"

#=====================================================================
# 2. CHECK & INSTALL TOOLS
#=====================================================================
TOOLS=(
    "go|go|Install Go Language"
    "subfinder|github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest|Subdomain Enumerator"
    "gau|github.com/lc/gau/v2/cmd/gau@latest|URL Fetcher"
    "httpx|github.com/projectdiscovery/httpx/cmd/httpx@latest|HTTP Prober"
)

install_go() {
    if command -v go &>/dev/null; then
        msg "$BLUE" "skip" "Go is already installed"
        return 0
    fi
    msg "$YELLOW" "install" "Go Language"
    pkg install -y golang &>/dev/null
    export PATH="$PATH:$HOME/go/bin"
    msg "$GREEN" "done" "Go installed"
}

install_tool() {
    local bin=$1 repo=$2 name=$3
    local path="$HOME/go/bin/$bin"

    if [[ -f "$path" ]]; then
        msg "$BLUE" "skip" "$name is already installed"
        return 0
    fi

    msg "$YELLOW" "install" "$name"
    go install "$repo" &>/dev/null &
    local pid=$!
    local start=$(date +%s)
    local est=90

    while kill -0 $pid 2>/dev/null; do
        local now=$(date +%s)
        local elapsed=$(( now - start ))
        (( elapsed > est )) && elapsed=$est
        local percent=$(( elapsed * 100 / est ))
        local remain=$(( est - elapsed ))
        (( remain < 0 )) && remain=0

        local bar=$(printf "%-${percent}s" "#" | tr ' ' '#')
        local empty=$(printf "%-$((100 - percent))s" "-" | tr ' ' '-')
        printf "\r[${BLUE}%s${NC}%s] %3d%% | ETA: %2ds" "$bar" "$empty" "$percent" "$remain"
        sleep 1
    done
    wait $pid 2>/dev/null || true
    printf "\n"

    if [[ -f "$path" ]]; then
        msg "$GREEN" "done" "$name installed"
    else
        msg "$RED" "error" "$name failed to install"
        exit 1
    fi
}

check_and_install_tools() {
    msg "$CYAN" "check" "Checking required tools..."

    install_go

    for tool in "${TOOLS[@]}"; do
        IFS='|' read -r bin repo name <<< "$tool"
        [[ "$bin" == "go" ]] && continue
        install_tool "$bin" "$repo" "$name"
    done

    # FORCE RELOAD PATH AFTER INSTALL
    export PATH="$PATH:$HOME/go/bin"
    msg "$GREEN" "done" "All tools are ready!"
}

#=====================================================================
# 3. INPUT & WORKSPACE
#=====================================================================
DOMAIN=""
WORKDIR=""

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain) DOMAIN="$2"; shift 2 ;;
            -h|--help)
                cat <<EOF
Usage: $0 [-d <domain>]
Example: $0 -d google.com
EOF
                exit 0
                ;;
            *) msg "$RED" "error" "Unknown option: $1"; exit 1 ;;
        esac
    done
}

setup_workspace() {
    local d=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')
    WORKDIR="$HOME/recon-$d"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
    msg "$CYAN" "check" "Workspace: $WORKDIR"
}

#=====================================================================
# 4. SCAN PHASES
#=====================================================================
run_subfinder() {
    msg "$GREEN" "subfinder" "$DOMAIN"
    subfinder -d "$DOMAIN" -silent -o subfinder.txt || { msg "$RED" "error" "subfinder failed"; exit 1; }
}

run_gau() {
    msg "$GREEN" "gau" "$DOMAIN"
    gau "$DOMAIN" --silent > gau.txt || { msg "$RED" "error" "gau failed"; exit 1; }
}

merge_urls() {
    msg "$YELLOW" "merge" "Combining results..."
    cat subfinder.txt gau.txt 2>/dev/null | sort -u > combined.txt
    local total=$(wc -l < combined.txt)
    msg "$YELLOW" "total" "$total"
}

run_httpx() {
    msg "$GREEN" "httpx" ""
    httpx -list combined.txt -silent -status-code -title -follow-redirects -o httpx.txt || { msg "$RED" "error" "httpx failed"; exit 1; }
    local live=$(grep -c "200" httpx.txt || echo 0)
    msg "$GREEN" "live" "$live"
}

generate_report() {
    local report="REPORT.txt"
    {
        echo "=== RECON REPORT ==="
        echo "Target : $DOMAIN"
        echo "Date   : $(date)"
        echo "------------------------------------------------"
        echo "Subdomains : $(wc -l < subfinder.txt 2>/dev/null || echo 0)"
        echo "URLs (gau) : $(wc -l < gau.txt 2>/dev/null || echo 0)"
        echo "Merged     : $(wc -l < combined.txt)"
        echo "Live (200) : $(grep -c "200" httpx.txt || echo 0)"
        echo "------------------------------------------------"
        echo "Top 10 Live URLs:"
        grep "200" httpx.txt | head -10
    } > "$report"
    msg "$GREEN" "report" "$WORKDIR/$report"
}

#=====================================================================
# 5. MAIN
#=====================================================================
main() {
    parse_args "$@"

    [[ -z "$DOMAIN" ]] && {
        msg "$CYAN" "domain"
        read -r DOMAIN
    }
    [[ -z "$DOMAIN" ]] && { msg "$RED" "error" "No domain provided"; exit 1; }

    check_and_install_tools
    setup_workspace
    run_subfinder
    run_gau
    merge_urls
    run_httpx
    generate_report

    echo -e "${GREEN}Recon completed successfully!${NC}"
}

main "$@"