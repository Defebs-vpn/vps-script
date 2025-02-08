#!/bin/bash
# Domain Management Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:22:53

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Function to add domain
add_domain() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         ADD NEW DOMAIN                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    read -p "Enter your domain: " domain
    if [ -z $domain ]; then
        echo -e "${RED}Please input domain${NC}"
        return
    fi
    
    # Check if domain resolves to server IP
    SERVER_IP=$(curl -s ipv4.icanhazip.com)
    DOMAIN_IP=$(dig +short $domain)
    
    if [ "$SERVER_IP" != "$DOMAIN_IP" ]; then
        echo -e "${RED}Domain $domain is not pointing to this server${NC}"
        echo -e "Server IP: $SERVER_IP"
        echo -e "Domain IP: $DOMAIN_IP"
        return
    fi
    
    # Save domain
    echo $domain > /etc/xray/domain
    
    # Update SSL certificate
    echo -e "${YELLOW}Updating SSL certificate...${NC}"
    systemctl stop nginx
    
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    ~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
    ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
    
    systemctl start nginx
    
    echo -e "${GREEN}Domain and SSL certificate updated successfully${NC}"
}

# Function to renew SSL certificate
renew_ssl() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         RENEW SSL CERTIFICATE         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    domain=$(cat /etc/xray/domain)
    echo -e "Current domain: ${CYAN}$domain${NC}"
    echo -e ""
    
    echo -e "${YELLOW}Renewing SSL certificate...${NC}"
    systemctl stop nginx
    
    ~/.acme.sh/acme.sh --renew -d $domain --force --ecc
    
    systemctl start nginx
    
    echo -e "${GREEN}SSL certificate renewed successfully${NC}"
}

# Function to check SSL status
check_ssl() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SSL CERTIFICATE STATUS        ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    domain=$(cat /etc/xray/domain)
    echo -e "Domain: ${CYAN}$domain${NC}"
    echo -e ""
    
    if [ -f "/etc/xray/xray.crt" ]; then
        cert_info=$(openssl x509 -in /etc/xray/xray.crt -text)
        echo -e "Certificate Information:"
        echo -e "${YELLOW}$(echo "$cert_info" | grep "Not Before")${NC}"
        echo -e "${YELLOW}$(echo "$cert_info" | grep "Not After")${NC}"
        echo -e ""
        
        # Check expiry
        exp_date=$(echo "$cert_info" | grep "Not After" | cut -d: -f2-)
        exp_epoch=$(date -d "$exp_date" +%s)
        current_epoch=$(date +%s)
        days_left=$(( ($exp_epoch - $current_epoch) / 86400 ))
        
        if [ $days_left -lt 30 ]; then
            echo -e "${RED}Warning: Certificate will expire in $days_left days${NC}"
        else
            echo -e "${GREEN}Certificate is valid for $days_left days${NC}"
        fi
    else
        echo -e "${RED}SSL certificate not found${NC}"
    fi
}

# Function to configure auto-renewal
configure_auto_renewal() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}       AUTO RENEWAL CONFIGURATION      ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Create renewal script
    cat > /usr/local/bin/ssl-renew <<END
#!/bin/bash
domain=\$(cat /etc/xray/domain)
~/.acme.sh/acme.sh --renew -d \$domain --force --ecc
systemctl restart nginx xray
echo "\$(date) - SSL certificate renewed" >> /var/log/ssl-renewal.log
END
    
    chmod +x /usr/local/bin/ssl-renew
    
    # Add to crontab
    echo "0 0 1 * * root /usr/local/bin/ssl-renew" > /etc/cron.d/ssl-renew
    
    echo -e "${GREEN}Auto-renewal configured to run monthly${NC}"
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         DOMAIN MANAGEMENT             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "Current Domain: ${CYAN}$(cat /etc/xray/domain)${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Add/Change Domain"
    echo -e " [${GREEN}2${NC}] Renew SSL Certificate"
    echo -e " [${GREEN}3${NC}] Check SSL Status"
    echo -e " [${GREEN}4${NC}] Configure Auto-Renewal"
    echo -e " [${GREEN}5${NC}] View SSL Logs"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_domain
        
        case $menu_domain in
            1) add_domain ;;
            2) renew_ssl ;;
            3) check_ssl ;;
            4) configure_auto_renewal ;;
            5)
                if [ -f "/var/log/ssl-renewal.log" ]; then
                    clear
                    echo -e "${CYAN}SSL Renewal Logs:${NC}"
                    cat /var/log/ssl-renewal.log
                    echo -e ""
                    read -n 1 -s -r -p "Press any key to continue"
                else
                    echo -e "${RED}No SSL renewal logs found${NC}"
                    sleep 2
                fi
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