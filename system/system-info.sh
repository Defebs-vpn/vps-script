#!/bin/bash
# System Information Script
# By: Defebs-vpn
# Current Date: 2025-02-07 15:30:12

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Get System Information
HOSTNAME=$(hostname)
OS=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
KERNEL=$(uname -r)
ARCH=$(uname -m)
IPVPS=$(curl -s ipv4.icanhazip.com)
DOMAIN=$(cat /etc/xray/domain)

# Get Resource Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
RAM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
RAM_USED=$(free -m | grep Mem | awk '{print $3}')
RAM_FREE=$(free -m | grep Mem | awk '{print $4}')
DISK_TOTAL=$(df -h --total | grep total | awk '{print $2}')
DISK_USED=$(df -h --total | grep total | awk '{print $3}')
DISK_FREE=$(df -h --total | grep total | awk '{print $4}')

# Get Service Status
SSH_SERVICE=$(systemctl is-active ssh)
DROPBEAR_SERVICE=$(systemctl is-active dropbear)
STUNNEL_SERVICE=$(systemctl is-active stunnel4)
XRAY_SERVICE=$(systemctl is-active xray)
NGINX_SERVICE=$(systemctl is-active nginx)
WS_SERVICE=$(systemctl is-active ws-epro)

# Get Connection Count
SSH_CONNECTED=$(netstat -natp | grep ESTABLISHED | grep ssh | wc -l)
DROPBEAR_CONNECTED=$(netstat -natp | grep ESTABLISHED | grep dropbear | wc -l)
XRAY_CONNECTED=$(netstat -natp | grep ESTABLISHED | grep xray | wc -l)

# Display Banner
clear
echo -e "$banner"

# Display System Information
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}              SYSTEM INFORMATION              ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "${CYAN}System Information:${NC}"
echo -e " ➣ Hostname    : $HOSTNAME"
echo -e " ➣ OS          : $OS"
echo -e " ➣ Kernel      : $KERNEL"
echo -e " ➣ Arch        : $ARCH"
echo -e " ➣ IP          : $IPVPS"
echo -e " ➣ Domain      : $DOMAIN"
echo -e ""
echo -e "${CYAN}Resource Usage:${NC}"
echo -e " ➣ CPU Usage   : ${CPU_USAGE}%"
echo -e " ➣ RAM Usage   : $RAM_USED MB / $RAM_TOTAL MB"
echo -e " ➣ RAM Free    : $RAM_FREE MB"
echo -e " ➣ Disk Usage  : $DISK_USED / $DISK_TOTAL"
echo -e " ➣ Disk Free   : $DISK_FREE"
echo -e ""
echo -e "${CYAN}Service Status:${NC}"
echo -e " ➣ SSH         : ${GREEN}$SSH_SERVICE${NC} ($SSH_CONNECTED connections)"
echo -e " ➣ Dropbear    : ${GREEN}$DROPBEAR_SERVICE${NC} ($DROPBEAR_CONNECTED connections)"
echo -e " ➣ Stunnel4    : ${GREEN}$STUNNEL_SERVICE${NC}"
echo -e " ➣ XRAY        : ${GREEN}$XRAY_SERVICE${NC} ($XRAY_CONNECTED connections)"
echo -e " ➣ Nginx       : ${GREEN}$NGINX_SERVICE${NC}"
echo -e " ➣ WebSocket   : ${GREEN}$WS_SERVICE${NC}"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check System Warnings
if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
    echo -e "${RED}WARNING: High CPU usage detected!${NC}"
fi

if (( $(echo "$RAM_USED/$RAM_TOTAL*100" | bc -l) > 80 )); then
    echo -e "${RED}WARNING: High RAM usage detected!${NC}"
fi

if (( $(df / | awk 'END{print $5}' | sed 's/%//') > 80 )); then
    echo -e "${RED}WARNING: Disk space is running low!${NC}"
fi

# Log System Status
LOG_FILE="/var/log/system-monitor.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') - CPU: ${CPU_USAGE}%, RAM: ${RAM_USED}/${RAM_TOTAL}MB, Disk: ${DISK_USED}/${DISK_TOTAL}" >> $LOG_FILE