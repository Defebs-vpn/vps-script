#!/bin/bash
# VMESS Menu Script
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

# Check VMESS User
check_vmess_user() {
    data=( `cat /etc/xray/vmess.db | grep '^###' | cut -d ' ' -f 2`);
    now=`date +"%Y-%m-%d"`
    for user in "${data[@]}"
    do
        exp=$(grep -w "^### $user" "/etc/xray/vmess.db" | cut -d ' ' -f 3)
        d1=$(date -d "$exp" +%s)
        d2=$(date -d "$now" +%s)
        exp2=$(( (d1 - d2) / 86400 ))
        if [[ "$exp2" -le "0" ]]; then
            echo $user > /etc/xray/vmess_expired.db
        fi
    done
}

# Display VMESS Menu
vmess_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}             VMESS MANAGER               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create VMESS Account"
    echo -e " [${GREEN}2${NC}] Delete VMESS Account"
    echo -e " [${GREEN}3${NC}] Extend VMESS Account"
    echo -e " [${GREEN}4${NC}] Check VMESS User Login"
    echo -e " [${GREEN}5${NC}] Check VMESS User Account"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Extend VMESS Account
extend_vmess() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}          EXTEND VMESS ACCOUNT           ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # List current users
    grep "^### " "/etc/xray/vmess.db" | cut -d ' ' -f 2-3 | nl -s ') '
    echo -e ""
    read -p "Select user number to extend: " number
    
    user=$(grep "^### " "/etc/xray/vmess.db" | cut -d ' ' -f 2 | sed -n "${number}"p)
    if [ -z $user ]; then
        echo -e "${RED}User does not exist${NC}"
        sleep 1
        menu-vmess
        exit 0
    fi
    
    read -p "Extend duration (days): " duration
    if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Please input numbers only${NC}"
        sleep 1
        menu-vmess
        exit 0
    fi
    
    exp=$(grep -w "^### $user" "/etc/xray/vmess.db" | cut -d ' ' -f 3)
    now=$(date -d "$exp" +%Y-%m-%d)
    new_exp=$(date -d "$now + $duration days" +%Y-%m-%d)
    
    sed -i "s/### $user $exp/### $user $new_exp/g" /etc/xray/vmess.db
    
    echo -e ""
    echo -e "${GREEN}VMESS Account $user has been extended to: $new_exp${NC}"
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
    menu-vmess
}

# Check VMESS User Login
check_vmess_login() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         VMESS USER LOGIN STATUS         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    data=( `cat /etc/xray/vmess.db | grep '^###' | cut -d ' ' -f 2`);
    for user in "${data[@]}"
    do
        status=$(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | awk '{print $5}' | cut -d: -f1 | sort | uniq | nl)
        if [[ -z "$status" ]]; then
            status="${RED}Not Connected${NC}"
        else
            status="${GREEN}Connected${NC}"
        fi
        echo -e " User: $user - Status: $status"
    done
    
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
    menu-vmess
}

# Main Function
check_vmess_user
vmess_menu
echo -e ""
read -p "Select From Options [ 0 - 5 ] : " menu_vmess

case $menu_vmess in
    1)
        add-vmess
        ;;
    2)
        del-vmess
        ;;
    3)
        extend_vmess
        ;;
    4)
        check_vmess_login
        ;;
    5)
        cat /etc/xray/vmess.db
        echo -e ""
        read -n 1 -s -r -p "Press any key to continue"
        menu-vmess
        ;;
    0)
        menu
        ;;
    *)
        echo -e "${RED}Please enter an correct number${NC}"
        sleep 1
        menu-vmess
        ;;
esac