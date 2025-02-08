#!/bin/bash
# System Status Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:43:45

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Function to check service status
check_service() {
    local service=$1
    local status=$(systemctl is-active $service)
    if [ "$status" == "active" ]; then
        echo -e "${GREEN}Running${NC}"
    else
        echo -e "${RED}Not Running${NC}"
    fi
}

# Display system status
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}           SYSTEM STATUS                 ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# System Information
echo -e "${CYAN}System Information:${NC}"
echo -e "OS          : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo -e "Kernel      : $(uname -r)"
echo -e "Uptime      : $(uptime -p | cut -d " " -f 2-10)"
echo -e "CPU Load    : $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo -e "Memory Used : $(free -m | grep Mem | awk '{printf("%.2f%"), $3/$2*100}')"
echo -e "Disk Used   : $(df -h / | awk 'NR==2 {print $5}')"
echo -e ""

# Service Status
echo -e "${CYAN}Service Status:${NC}"
echo -e "SSH         : $(check_service ssh)"
echo -e "Dropbear    : $(check_service dropbear)"
echo -e "Stunnel4    : $(check_service stunnel4)"
echo -e "XRAY        : $(check_service xray)"
echo -e "Nginx       : $(check_service nginx)"
echo -e "WebSocket   : $(check_service ws-epro)"
echo -e ""

# Network Status
echo -e "${CYAN}Network Status:${NC}"
echo -e "IP          : $(curl -s ipv4.icanhazip.com)"
echo -e "Domain      : $(cat /etc/xray/domain)"
echo -e "ISP         : $(curl -s ipinfo.io/org)"
echo -e "Location    : $(curl -s ipinfo.io/city), $(curl -s ipinfo.io/country)"
echo -e ""

# User Status
echo -e "${CYAN}User Status:${NC}"
echo -e "SSH Users   : $(grep -c '^###' /etc/ssh/ssh.db) users"
echo -e "VMESS Users : $(grep -c '^###' /etc/xray/vmess.db) users"
echo -e "VLESS Users : $(grep -c '^###' /etc/xray/vless.db) users"
echo -e "Trojan Users: $(grep -c '^###' /etc/xray/trojan.db) users"
echo -e ""

# Traffic Status
echo -e "${CYAN}Traffic Status:${NC}"
echo -e "Download    : $(vnstat -i eth0 -h 1 | grep rx | awk '{print $2 $3}')"
echo -e "Upload      : $(vnstat -i eth0 -h 1 | grep tx | awk '{print $2 $3}')"
echo -e "Total       : $(vnstat -i eth0 -h 1 | grep total | awk '{print $2 $3}')"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"