
---

DevSec-Recon

DevSec-Recon is an advanced and automated reconnaissance tool for Bug Bounty hunters and penetration testers. It performs subdomain enumeration, asset validation, URL collection, and filters for vulnerability scanning using tools like subfinder, httpx, and gau. The tool ensures a clean, professional interface with progress bars and stylish terminal output.

Features

Automatically detects and installs missing dependencies

Enumerates subdomains using subfinder and amass

Probes live hosts with httpx

Collects URLs using gau

Saves all results in organized output files

Stylish UI with progress bars and loading effects

Fully automated workflow, ideal for reconnaissance automation

English-only interface for professional output



---

Installation

git clone https://github.com/devsec23/DevSec-Recon.git
cd DevSec-Recon
chmod +x devsec_recon.sh

Usage

./devsec_recon.sh target.com

Replace target.com with your target domain.
The tool will:

Create an output directory for the target

Run subdomain enumeration using subfinder and amass

Check which domains are alive using httpx

Extract URLs from archived data using gau

Save the results to:

subdomains.txt

httpx_alive.txt

gau_urls.txt



All output is stored in the output/target.com/ directory.


---

Example

./devsec_recon.sh example.com

Output:

[+] Starting DevSec-Recon on example.com
[✔] Subdomains saved to output/example.com/subdomains.txt
[✔] Alive hosts saved to output/example.com/httpx_alive.txt
[✔] URLs saved to output/example.com/gau_urls.txt


---

Requirements

The script handles installing these automatically if missing:

subfinder

amass

httpx

gau

jq

curl


Make sure you're on Linux or WSL (Windows Subsystem for Linux).
It is also compatible with Cloud Shell and VPS environments.


---

Credits

Created with passion by devsec23


---
