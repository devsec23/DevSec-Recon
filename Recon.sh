#!/usr/bin/env bash
#=====================================================================
# Recon Tool – Subfinder + Gau + Httpx
# المؤلف:  DevSec Zone
# الإصدار: 2.0
#=====================================================================

set -euo pipefail   # أمان أكثر

# ---------- ألوان ----------
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------- لغة الرسائل ----------
LANG="ar"   # غيّر إلى "en" للإنجليزية

msg() {
    local color=$1; shift
    if [[ $LANG == "ar" ]]; then
        case $1 in
            "install")   echo -e "${color}جاري تثبيت الأدوات …${NC}" ;;
            "done")      echo -e "${color}تم التثبيت بنجاح${NC}" ;;
            "domain")    echo -e "${color}أدخل الدومين للمسح:${NC}" ;;
            "subfinder") echo -e "${color}جاري تشغيل subfinder على $2 …${NC}" ;;
            "gau")       echo -e "${color}جاري تشغيل gau على $2 …${NC}" ;;
            "httpx")     echo -e "${color}جاري فحص الروابط الحية …${NC}" ;;
            "live")      echo -e "${color}عدد الروابط الحية: $2${NC}" ;;
            "total")     echo -e "${color}إجمالي الروابط المدمجة: $2${NC}" ;;
            "report")    echo -e "${color}تم إنشاء التقرير في $2${NC}" ;;
            "error")     echo -e "${RED}خطأ: $2${NC}" ;;
            *)           echo -e "${color}$1${NC}" ;;
        esac
    else
        case $1 in
            "install")   echo -e "${color}Installing tools …${NC}" ;;
            "done")      echo -e "${color}Installation done${NC}" ;;
            "domain")    echo -e "${color}Enter domain to scan:${NC}" ;;
            "subfinder") echo -e "${color}Running subfinder on $2 …${NC}" ;;
            "gau")       echo -e "${color}Running gau on $2 …${NC}" ;;
            "httpx")     echo -e "${color}Probing live URLs …${NC}" ;;
            "live")      echo -e "${color}Live URLs: $2${NC}" ;;
            "total")     echo -e "${color}Total merged URLs: $2${NC}" ;;
            "report")    echo -e "${color}Report saved to $2${NC}" ;;
            "error")     echo -e "${RED}ERROR: $2${NC}" ;;
            *)           echo -e "${color}$1${NC}" ;;
        esac
    fi
}

# ---------- تثبيت Go إذا لم يكن موجود ----------
install_go() {
    if ! command -v go &>/dev/null; then
        msg "$YELLOW" "install"
        pkg install -y golang &>/dev/null
        # إضافة go bin إلى PATH دائمًا
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$HOME/.bashrc"
        export PATH=$PATH:$HOME/go/bin
    fi
}

# ---------- التحقق من وجود الأداة ----------
tool_installed() {
    local bin=$1
    [[ -f "$HOME/go/bin/$bin" ]] || return 1
}

# ---------- تثبيت الأدوات (صامت) ----------
install_tool() {
    local repo=$1 bin=$2
    if tool_installed "$bin"; then
        return 0
    fi
    msg "$YELLOW" "install"
    go install "$repo@latest" &>/dev/null &
    local pid=$!
    # شريط تقدّم بسيط
    while kill -0 $pid 2>/dev/null; do
        printf "."
        sleep 1
    done
    wait $pid
    printf "\n"
}

install_tools() {
    install_go
    install_tool "github.com/projectdiscovery/subfinder/v2/cmd/subfinder" "subfinder"
    install_tool "github.com/lc/gau/v2/cmd/gau"                       "gau"
    install_tool "github.com/projectdiscovery/httpx/cmd/httpx"       "httpx"
    msg "$GREEN" "done"
}

# ---------- معالجة الإدخال ----------
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
                exit 0
                ;;
            *)
                msg "$RED" "error" "خيار غير معروف: $1"
                exit 1
                ;;
        esac
    done
}

# ---------- إنشاء مجلد عمل ----------
setup_workspace() {
    local d=$(echo "$DOMAIN" | tr '[:upper:]' '[:lower:]')
    WORKDIR="$HOME/recon-$d"
    mkdir -p "$WORKDIR"
    cd "$WORKDIR"
}

# ---------- تشغيل الأدوات ----------
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
        echo "=== تقرير Recon لـ $DOMAIN ==="
        echo "تاريخ: $(date)"
        echo
        echo "Subdomains  : $(wc -l < subfinder.txt)   (subfinder.txt)"
        echo "URLs (gau)  : $(wc -l < gau.txt)       (gau.txt)"
        echo "Merged URLs : $(wc -l < combined.txt)  (combined.txt)"
        echo "Live URLs   : $(grep -c "200" httpx.txt) (httpx.txt)"
        echo
        echo "=== أول 10 روابط حية ==="
        grep "200" httpx.txt | head -10
    } > "$report"
    msg "$GREEN" "report" "$WORKDIR/$report"
}

# ---------- التنفيذ الرئيسي ----------
main() {
    parse_args "$@"

    # إذا لم يُمرر دومين من سطر الأوامر → طلب إدخال
    if [[ -z "$DOMAIN" ]]; then
        msg "$YELLOW" "domain"
        read -r DOMAIN
    fi

    [[ -z "$DOMAIN" ]] && { msg "$RED" "error" "لم يتم إدخال دومين"; exit 1; }

    install_tools
    setup_workspace

    run_subfinder
    run_gau
    merge_urls
    run_httpx
    generate_report

    msg "$GREEN" "All tools executed successfully."
}

# تشغيل الدالة الرئيسية
main "$@"