#!/bin/bash
# Port Change Menu Script
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

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}            PORT MANAGER                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Change SSH Port"
    echo -e " [${GREEN}2${NC}] Change Dropbear Port"
    echo -e " [${GREEN}3${NC}] Change Stunnel Port"
    echo -e " [${GREEN}4${NC}] Change XRAY Port"
    echo -e " [${GREEN}5${NC}] Change WebSocket Port"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to change SSH port
change_ssh_port() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           CHANGE SSH PORT              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    read -p "New SSH Port : " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Please input numbers only${NC}"
        return
    fi
    
    # Change SSH port
    sed -i "s/#Port 22/Port $port/g" /etc/ssh/sshd_config
    sed -i "s/Port 22/Port $port/g" /etc/ssh/sshd_config
    
    systemctl restart ssh
    echo -e "${GREEN}SSH Port changed to: $port${NC}"
}

# Function to change Dropbear port
change_dropbear_port() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CHANGE DROPBEAR PORT           ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    read -p "New Dropbear Port : " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Please input numbers only${NC}"
        return
    fi
    
    # Change Dropbear port
    sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=$port/g" /etc/default/dropbear
    
    systemctl restart dropbear
    echo -e "${GREEN}Dropbear Port changed to: $port${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_port
        
        case $menu_port in
            1) change_ssh_port ;;
            2) change_dropbear_port ;;
            3) change_stunnel_port ;;
            4) change_xray_port ;;
            5) change_ws_port ;;
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