#!/bin/bash
# Port Management Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:27:51

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Configuration files
XRAY_CONFIG="/etc/xray/config.json"
NGINX_CONFIG="/etc/nginx/conf.d/xray.conf"

# Function to check if port is in use
check_port() {
    local port=$1
    netstat -tuln | grep -q ":$port "
    return $?
}

# Function to validate port number
validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ $port -lt 1 ] || [ $port -gt 65535 ]; then
        return 1
    fi
    return 0
}

# Function to change XRAY port
change_xray_port() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CHANGE XRAY PORT              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    current_port=$(grep -oP '(?<="port": )[0-9]+' $XRAY_CONFIG | head -1)
    echo -e "Current XRAY port: ${CYAN}$current_port${NC}"
    echo -e ""
    
    read -p "Enter new port: " new_port
    
    if ! validate_port $new_port; then
        echo -e "${RED}Invalid port number${NC}"
        return
    fi
    
    if check_port $new_port; then
        echo -e "${RED}Port $new_port is already in use${NC}"
        return
    fi
    
    # Update XRAY config
    sed -i "s/\"port\": $current_port/\"port\": $new_port/" $XRAY_CONFIG
    
    # Update Nginx config
    sed -i "s/proxy_pass http:\/\/127.0.0.1:$current_port/proxy_pass http:\/\/127.0.0.1:$new_port/" $NGINX_CONFIG
    
    systemctl restart xray nginx
    echo -e "${GREEN}XRAY port has been changed to $new_port${NC}"
}

# Function to change WebSocket port
change_ws_port() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CHANGE WEBSOCKET PORT         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    current_port=$(grep -oP 'listen \K[0-9]+' /etc/nginx/conf.d/ws.conf)
    echo -e "Current WebSocket port: ${CYAN}$current_port${NC}"
    echo -e ""
    
    read -p "Enter new port: " new_port
    
    if ! validate_port $new_port; then
        echo -e "${RED}Invalid port number${NC}"
        return
    fi
    
    if check_port $new_port; then
        echo -e "${RED}Port $new_port is already in use${NC}"
        return
    fi
    
    # Update WebSocket config
    sed -i "s/listen $current_port/listen $new_port/" /etc/nginx/conf.d/ws.conf
    
    systemctl restart nginx
    echo -e "${GREEN}WebSocket port has been changed to $new_port${NC}"
}

# Function to show all used ports
show_ports() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         ACTIVE PORTS                  ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    echo -e "${CYAN}TCP Ports:${NC}"
    netstat -tuln | grep "LISTEN" | grep "tcp" | awk '{print $4}' | cut -d: -f2 | sort -n | uniq | \
    while read port; do
        service=$(lsof -i :$port | grep LISTEN | awk '{print $1}' | head -1)
        echo -e "Port ${GREEN}$port${NC}: $service"
    done
    
    echo -e "\n${CYAN}UDP Ports:${NC}"
    netstat -tuln | grep "udp" | awk '{print $4}' | cut -d: -f2 | sort -n | uniq | \
    while read port; do
        service=$(lsof -i :$port | grep UDP | awk '{print $1}' | head -1)
        echo -e "Port ${GREEN}$port${NC}: $service"
    done
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         PORT MANAGEMENT               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Change XRAY Port"
    echo -e " [${GREEN}2${NC}] Change WebSocket Port"
    echo -e " [${GREEN}3${NC}] Show Active Ports"
    echo -e " [${GREEN}4${NC}] Port Forwarding"
    echo -e " [${GREEN}5${NC}] Port Security"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_port
        
        case $menu_port in
            1) change_xray_port ;;
            2) change_ws_port ;;
            3) 
                show_ports
                echo -e ""
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            4)
                echo -e "${YELLOW}Port forwarding feature coming soon${NC}"
                sleep 2
                ;;
            5)
                echo -e "${YELLOW}Port security feature coming soon${NC}"
                sleep 2
                ;;
            0) break ;;
            *)
                echo -e "${RED}Please enter an correct number${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run main function
main