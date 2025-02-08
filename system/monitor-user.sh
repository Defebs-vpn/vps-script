#!/bin/bash
# User Monitoring Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:15:00

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Function to check SSH users
check_ssh_users() {
    echo -e "${CYAN}SSH Users:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    data=( `cat /etc/passwd | grep '/home/' | cut -d ':' -f1`);
    for user in "${data[@]}"
    do
        exp=$(chage -l $user | grep "Account expires" | awk -F": " '{print $2}')
        if [[ $exp == "never" ]]; then
            exp="Never"
        fi
        login=$(ps aux | grep -w "$user" | grep -v grep | wc -l)
        printf "%-15s : %d sessions (Expires: %s)\n" "$user" "$login" "$exp"
    done
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check XRAY users
check_xray_users() {
    echo -e ""
    echo -e "${CYAN}XRAY Users:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for type in vmess vless trojan; do
        echo -e "${YELLOW}${type^^} Users:${NC}"
        if [ -f "/etc/xray/${type}.db" ]; then
            while read line; do
                if [[ $line == "### "* ]]; then
                    user=$(echo $line | awk '{print $2}')
                    exp=$(echo $line | awk '{print $3}')
                    login=$(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | grep -w 443 | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | grep -w $user | awk '{print $1}')
                    if [ -z "$login" ]; then
                        login=0
                    fi
                    printf "%-15s : %d sessions (Expires: %s)\n" "$user" "$login" "$exp"
                fi
            done < "/etc/xray/${type}.db"
        fi
    done
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to show active connections
show_connections() {
    echo -e ""
    echo -e "${CYAN}Active Connections:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    netstat -antp | grep ESTABLISHED | grep -v 127.0.0.1 | awk '{print $4,$5,$7}' | column -t
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         USER MONITORING               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Show All Users"
    echo -e " [${GREEN}2${NC}] Monitor SSH Users"
    echo -e " [${GREEN}3${NC}] Monitor XRAY Users"
    echo -e " [${GREEN}4${NC}] Show Active Connections"
    echo -e " [${GREEN}5${NC}] Kill User Connection"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to kill user connection
kill_connection() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         KILL USER CONNECTION          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    read -p "Enter username to kill: " user
    if [ -z $user ]; then
        echo -e "${RED}Please input username${NC}"
        return
    fi
    
    pid=$(ps aux | grep -w "$user" | grep -v grep | awk '{print $2}')
    if [ ! -z "$pid" ]; then
        kill -9 $pid
        echo -e "${GREEN}User $user connections have been killed${NC}"
    else
        echo -e "${RED}No active connections found for user $user${NC}"
    fi
    
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_user
        
        case $menu_user in
            1)
                clear
                check_ssh_users
                check_xray_users
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            2)
                clear
                check_ssh_users
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            3)
                clear
                check_xray_users
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            4)
                clear
                show_connections
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            5)
                kill_connection
                ;;
            0)
                break
                ;;
            *)
                echo -e "${RED}Please enter an correct number${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run main function
main