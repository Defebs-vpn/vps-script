#!/bin/bash
# Main Menu Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:17:31

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Banner
banner() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}          AUTOSCRIPT BY DEFEBS-VPN         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "    ${GREEN}Domain     : $(cat /etc/xray/domain)"
    echo -e "    IP         : $(curl -s ipv4.icanhazip.com)"
    echo -e "    OS         : $(cat /etc/os-release | grep -w PRETTY_NAME | cut -d= -f2 | sed 's/"//g')"
    echo -e "    Kernel     : $(uname -r)"
    echo -e "    Up Time    : $(uptime -p | cut -d " " -f 2-10)${NC}"
    echo -e ""
}

# Menu Options
options() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${BG}            MAIN MENU                  ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] SSH & OpenVPN Menu"
    echo -e " [${GREEN}2${NC}] VMESS Menu"
    echo -e " [${GREEN}3${NC}] VLESS Menu"
    echo -e " [${GREEN}4${NC}] Trojan Menu"
    echo -e " [${GREEN}5${NC}] System Settings"
    echo -e " [${GREEN}6${NC}] Status Service"
    echo -e " [${GREEN}7${NC}] Clear RAM Cache"
    echo -e " [${GREEN}8${NC}] Backup & Restore"
    echo -e " [${GREEN}9${NC}] Reboot System"
    echo -e " [${GREEN}0${NC}] Exit Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main Menu Function
main_menu() {
    banner
    options
    echo -e ""
    read -p "Select From Options [ 0 - 9 ] : " menu
    case $menu in
        1)
            menu-ssh
            ;;
        2)
            menu-vmess
            ;;
        3)
            menu-vless
            ;;
        4)
            menu-trojan
            ;;
        5)
            menu-system
            ;;
        6)
            status
            ;;
        7)
            clear-cache
            ;;
        8)
            menu-backup
            ;;
        9)
            reboot
            ;;
        0)
            clear
            exit 0
            ;;
        *)
            echo -e "${RED}Please enter an correct number${NC}"
            sleep 1
            menu
            ;;
    esac
}

# Run main menu
main_menu