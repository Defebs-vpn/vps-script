#!/bin/bash
# Trojan Menu Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:38:08

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}            TROJAN MANAGER              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create Trojan Account"
    echo -e " [${GREEN}2${NC}] Delete Trojan Account"
    echo -e " [${GREEN}3${NC}] Extend Trojan Account"
    echo -e " [${GREEN}4${NC}] Check Trojan User Login"
    echo -e " [${GREEN}5${NC}] List Trojan Users"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Check Trojan User Login
check_trojan_login() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         TROJAN USER LOGIN STATUS       ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    data=( `cat /etc/xray/trojan.db | grep '^###' | cut -d ' ' -f 2`);
    for user in "${data[@]}"
    do
        status=$(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | grep -w 443 | awk '{print $5}' | cut -d: -f1 | sort | uniq | nl)
        if [[ -z "$status" ]]; then
            status="${RED}Not Connected${NC}"
        else
            status="${GREEN}Connected${NC}"
        fi
        echo -e " User: $user - Status: $status"
    done
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_trojan
        
        case $menu_trojan in
            1) add-trojan ;;
            2) del-trojan ;;
            3) renew-trojan ;;
            4) check_trojan_login ;;
            5) cat /etc/xray/trojan.db ;;
            0) menu ;;
            *)
                echo -e "${RED}Please enter an correct number${NC}"
                sleep 1
            ;;
        esac
    done
}

# Run main function
main