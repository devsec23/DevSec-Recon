#!/bin/bash

شعار الأداة

logo() { echo -e "\e[1;34m ██████╗ ███████╗██╗   ██╗███████╗███████╗███████╗ ██████╗ ██╔══██╗██╔════╝╚██╗ ██╔╝██╔════╝██╔════╝██╔════╝██╔═══██╗ ██║  ██║█████╗   ╚████╔╝ █████╗  █████╗  █████╗  ██║   ██║ ██║  ██║██╔══╝    ╚██╔╝  ██╔══╝  ██╔══╝  ██╔══╝  ██║   ██║ ██████╔╝███████╗   ██║   ███████╗███████╗███████╗╚██████╔╝ ╚═════╝ ╚══════╝   ╚═╝   ╚══════╝╚══════╝╚══════╝ ╚═════╝ \e[1;33mby devsec_recon\e[0m " }

عرض الشعار

logo

التحقق من الأدوات المطلوبة

check_tool() { if ! command -v $1 &> /dev/null; then echo -e "\e[1;31m[!] $1 غير مثبت، يتم تثبيته...\e[0m" go install github.com/projectdiscovery/$1/cmd/$1@latest || apt install -y $1 || echo "$1 لم يتم تثبيته." else echo -e "\e[1;32m[+] $1 مثبت بالفعل\e[0m" fi }

TOOLS=(subfinder httpx gau)

for tool in "${TOOLS[@]}"; do check_tool $tool done

متغيرات

TARGET=$1 OUT_DIR="results" mkdir -p $OUT_DIR

echo -e "\e[1;34m[*] بدء عملية recon على: $TARGET\e[0m"

جمع subdomains

subfinder -d $TARGET -all -silent -o $OUT_DIR/subdomains.txt

التأكد من أن الـ subdomains أونلاين

httpx -l $OUT_DIR/subdomains.txt -silent -o $OUT_DIR/online.txt

استخراج الروابط من wayback

gau --threads 5 -o $OUT_DIR/urls.txt $TARGET

echo -e "\e[1;32m[+] الانتهاء من الفحص. النتائج محفوظة في مجلد $OUT_DIR\e[0m"

