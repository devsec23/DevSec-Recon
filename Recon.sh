#!/bin/bash

# عرض شعار الأداة
echo -e "\033[1;32m
██████╗ ███████╗████████╗███████╗██████╗ ███████╗███████╗
██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔════╝
██████╔╝███████╗   ██║   █████╗  ██████╔╝███████╗███████╗
██╔═══╝ ██╔════╝   ██║   ██╔══╝  ██╔═══╝ ╚════██╗╚════██╗
██║     ███████╗   ██║   ███████╗██║     ███████╔╝██████╔╝
╚═╝     ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═════╝ ╚═════╝
\033[0m"

# المجال الهدف
read -p "أدخل اسم النطاق (domain): " domain

# إنشاء مجلد النتائج
mkdir -p results

# التحقق من وجود الأدوات وتثبيتها إذا لزم الأمر
for tool in subfinder httpx gau; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool غير مثبت. سيتم تثبيته..."
        go install github.com/projectdiscovery/$tool@latest 2>/dev/null || go install github.com/lc/gau/v2/cmd/gau@latest
    fi
done

# جمع السب دومينات
echo -e "\n[+] تشغيل subfinder..."
subfinder -d "$domain" -silent -o results/subdomains.txt

# فحص السيرفرات الحية
echo -e "\n[+] تشغيل httpx..."
cat results/subdomains.txt | httpx -silent -o results/httpx_output.txt

# جمع الروابط من الأرشيفات
echo -e "\n[+] تشغيل gau..."
gau "$domain" --o results/gau_output.txt

# ملخص
echo -e "\n\033[1;34m[✓] تم إكمال الفحص. النتائج محفوظة داخل مجلد 'results'.\033[0m"
