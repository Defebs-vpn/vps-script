#!/bin/bash
# SSH Menu Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:32:01

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
    echo -e "${BG}              SSH MANAGER                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create SSH Account"
    echo -e " [${GREEN}2${NC}] Delete SSH Account"
    echo -e " [${GREEN}3${NC}] Extend SSH Account"
    echo -e " [${GREEN}4${NC}] Check SSH User Login"
    echo -e " [${GREEN}5${NC}] List SSH Users"
    echo -e " [${GREEN}6${NC}] Monitor SSH Users"
    echo -e " [${GREEN}7${NC}] Change SSH Port"
    echo -e " [${GREEN}8${NC}] Auto Kill Multi Login"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Create SSH User
create_ssh_user() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           CREATE SSH ACCOUNT            ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    read -p "Username : " user
    read -p "Password : " pass
    read -p "Duration (days) : " duration
    
    # Check if user exists
    if id -u $user > /dev/null 2>&1; then
        echo -e "${RED}User already exists${NC}"
        return 1
    fi
    
    # Create user
    useradd -M -s /bin/false -e $(date -d "+${duration} days" +"%Y-%m-%d") $user
    echo "$user:$pass" | chpasswd
    
    # Add to database
    echo "### $user $(date -d "+${duration} days" +"%Y-%m-%d")" >> /etc/ssh/ssh.db
    
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SSH ACCOUNT DETAILS             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "Username   : $user"
    echo -e "Password   : $pass"
    echo -e "Expired On : $(date -d "+${duration} days" +"%Y-%m-%d")"
    echo -e ""
    echo -e "IP         : $(curl -s ipv4.icanhazip.com)"
    echo -e "Host       : $(cat /etc/xray/domain)"
    echo -e "SSH Port   : 22"
    echo -e "SSL Port   : 777"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Monitor SSH Users
monitor_ssh() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           SSH USER MONITOR              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    if [ -f /etc/ssh/ssh.db ]; then
        while read user exp; do
            if [[ $user != "###" ]]; then
                login=$(ps aux | grep -w "$user" | grep -v grep | wc -l)
                if [ $login -gt 0 ]; then
                    printf "%-15s : %s Sessions\n" "$user" "$login"
                fi
            fi
        done < /etc/ssh/ssh.db
    fi
    
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 8 ] : " menu_ssh
        
        case $menu_ssh in
            1) create_ssh_user ;;
            2) delete_ssh_user ;;
            3) extend_ssh_user ;;
            4) check_ssh_login ;;
            5) view_ssh_users ;;
            6) monitor_ssh ;;
            7) change_ssh_port ;;
            8) auto_kill ;;
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