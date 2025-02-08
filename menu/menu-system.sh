#!/bin/bash
# System Menu Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:24:16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# System Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           SYSTEM SETTINGS              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Change Domain"
    echo -e " [${GREEN}2${NC}] Change Port"
    echo -e " [${GREEN}3${NC}] Update SSL Certificate"
    echo -e " [${GREEN}4${NC}] System Monitoring"
    echo -e " [${GREEN}5${NC}] Check Resource Usage"
    echo -e " [${GREEN}6${NC}] Optimize System"
    echo -e " [${GREEN}7${NC}] SpeedTest"
    echo -e " [${GREEN}8${NC}] Update Script"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Change Domain
change_domain() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           CHANGE DOMAIN                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    read -p "Input your new domain : " domain
    if [ -z $domain ]; then
        echo -e "${RED}Please input domain${NC}"
        return
    fi
    
    # Update domain in configuration
    echo $domain > /etc/xray/domain
    
    # Update SSL certificate
    ~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    
    systemctl restart xray
    echo -e "${GREEN}Domain has been changed to: $domain${NC}"
}

# Update SSL Certificate
update_ssl() {
    domain=$(cat /etc/xray/domain)
    
    echo -e "${CYAN}Updating SSL Certificate for $domain${NC}"
    ~/.acme.sh/acme.sh --renew -d $domain --force
    
    systemctl restart xray
    echo -e "${GREEN}SSL Certificate has been updated${NC}"
}

# System Optimization
optimize_system() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}          SYSTEM OPTIMIZATION           ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Clear system cache
    echo -e "${CYAN}Clearing system cache...${NC}"
    sync; echo 3 > /proc/sys/vm/drop_caches
    
    # Optimize kernel parameters
    echo -e "${CYAN}Optimizing kernel parameters...${NC}"
    cat > /etc/sysctl.d/99-optimizer.conf <<END
net.ipv4.tcp_window_scaling = 1
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 16384 16777216
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_fastopen = 3
END
    sysctl --system
    
    # Clean package cache
    echo -e "${CYAN}Cleaning package cache...${NC}"
    apt-get clean
    apt-get autoremove -y
    
    echo -e "${GREEN}System optimization completed${NC}"
}

# SpeedTest
run_speedtest() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}             SPEEDTEST                  ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Install speedtest if not exists
    if ! command -v speedtest &> /dev/null; then
        curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash
        apt-get install speedtest -y
    fi
    
    echo -e "${CYAN}Running speedtest...${NC}"
    speedtest --progress=yes
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 8 ] : " menu_system
        
        case $menu_system in
            1) change_domain ;;
            2) change_port ;;
            3) update_ssl ;;
            4) system-monitor ;;
            5) htop ;;
            6) optimize_system ;;
            7) run_speedtest ;;
            8) update ;;
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