#!/bin/bash
# Security Configuration Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:11:22

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
    echo -e "${BG}         SECURITY SETTINGS              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Configure Fail2ban"
    echo -e " [${GREEN}2${NC}] Configure SSH Security"
    echo -e " [${GREEN}3${NC}] Configure Firewall"
    echo -e " [${GREEN}4${NC}] View Security Logs"
    echo -e " [${GREEN}5${NC}] Block Suspicious IPs"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Configure Fail2ban
configure_fail2ban() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         FAIL2BAN CONFIGURATION         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Install if not exists
    if ! command -v fail2ban-client &> /dev/null; then
        echo -e "${YELLOW}Installing Fail2ban...${NC}"
        apt-get install fail2ban -y
    fi
    
    # Configure Fail2ban
    cat > /etc/fail2ban/jail.local <<END
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3

[xray]
enabled = true
port = 443
filter = xray
logpath = /var/log/xray/access.log
maxretry = 3
END
    
    # Create XRAY filter
    cat > /etc/fail2ban/filter.d/xray.conf <<END
[Definition]
failregex = ^.* failed authentication attempt from <HOST>.*$
ignoreregex =
END
    
    systemctl restart fail2ban
    echo -e "${GREEN}Fail2ban configuration updated${NC}"
}

# Configure SSH Security
configure_ssh() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SSH SECURITY SETTINGS          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Backup original config
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    
    # Configure SSH
    sed -i 's/#PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 300/' /etc/ssh/sshd_config
    sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 2/' /etc/ssh/sshd_config
    
    systemctl restart ssh
    echo -e "${GREEN}SSH security settings updated${NC}"
}

# Configure Firewall
configure_firewall() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         FIREWALL CONFIGURATION        ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Install UFW if not exists
    if ! command -v ufw &> /dev/null; then
        echo -e "${YELLOW}Installing UFW...${NC}"
        apt-get install ufw -y
    fi
    
    # Configure UFW
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow 143/tcp
    ufw allow 109/tcp
    ufw allow 777/tcp
    
    echo "y" | ufw enable
    echo -e "${GREEN}Firewall configuration updated${NC}"
}

# View Security Logs
view_logs() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SECURITY LOGS                 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${CYAN}Failed SSH Attempts:${NC}"
    grep "Failed password" /var/log/auth.log | tail -n 5
    echo -e ""
    echo -e "${CYAN}Banned IPs (Fail2ban):${NC}"
    fail2ban-client status sshd | grep "Banned IP list"
    echo -e ""
    echo -e "${CYAN}Recent UFW Blocks:${NC}"
    grep "UFW BLOCK" /var/log/ufw.log | tail -n 5
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

# Block Suspicious IPs
block_ips() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         BLOCK SUSPICIOUS IPs          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "1) Block IP"
    echo -e "2) Unblock IP"
    echo -e "3) View Blocked IPs"
    echo -e "0) Back"
    echo -e ""
    read -p "Select option : " option
    
    case $option in
        1)
            read -p "Enter IP to block: " ip
            ufw deny from $ip
            echo -e "${GREEN}IP $ip has been blocked${NC}"
            ;;
        2)
            read -p "Enter IP to unblock: " ip
            ufw delete deny from $ip
            echo -e "${GREEN}IP $ip has been unblocked${NC}"
            ;;
        3)
            echo -e "${CYAN}Currently blocked IPs:${NC}"
            ufw status | grep DENY
            echo -e ""
            read -n 1 -s -r -p "Press any key to continue"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_security
        
        case $menu_security in
            1) configure_fail2ban ;;
            2) configure_ssh ;;
            3) configure_firewall ;;
            4) view_logs ;;
            5) block_ips ;;
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