#!/bin/bash
# Nginx Configuration Script
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

# Configuration directories
NGINX_DIR="/etc/nginx"
SITES_AVAILABLE="$NGINX_DIR/sites-available"
SITES_ENABLED="$NGINX_DIR/sites-enabled"

# Function to install/update Nginx
install_nginx() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         INSTALL/UPDATE NGINX          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Add Nginx mainline repository
    echo -e "${YELLOW}Adding Nginx repository...${NC}"
    echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    
    apt-get update
    apt-get install -y nginx
    
    # Create necessary directories
    mkdir -p $SITES_AVAILABLE $SITES_ENABLED
    
    echo -e "${GREEN}Nginx installed/updated successfully${NC}"
}

# Function to configure XRAY with Nginx
configure_xray() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CONFIGURE XRAY NGINX          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    domain=$(cat /etc/xray/domain)
    
    # Create Nginx configuration for XRAY
    cat > $SITES_AVAILABLE/xray.conf <<END
server {
    listen 443 ssl http2;
    server_name $domain;
    
    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /var/www/html;
    
    location / {
        try_files \$uri \$uri/ /index.html;
    }
    
    location /xray {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
}

server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}
END
    
    # Enable configuration
    ln -sf $SITES_AVAILABLE/xray.conf $SITES_ENABLED/
    
    # Test configuration
    nginx -t
    
    systemctl restart nginx
    echo -e "${GREEN}XRAY Nginx configuration completed${NC}"
}

# Function to optimize Nginx
optimize_nginx() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         OPTIMIZE NGINX                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Backup original configuration
    cp $NGINX_DIR/nginx.conf $NGINX_DIR/nginx.conf.bak
    
    # Optimize Nginx configuration
    cat > $NGINX_DIR/nginx.conf <<END
user www-data;
worker_processes auto;
worker_rlimit_nofile 65535;
pid /var/run/nginx.pid;

events {
    multi_accept on;
    worker_connections 65535;
}

http {
    charset utf-8;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    server_tokens off;
    log_not_found off;
    types_hash_max_size 2048;
    client_max_body_size 16M;
    
    # MIME
    include mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log warn;
    
    # SSL
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    
    # Diffie-Hellman parameter for DHE ciphersuites
    ssl_dhparam /etc/nginx/dhparam.pem;
    
    # Mozilla Intermediate configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4 valid=60s;
    resolver_timeout 2s;
    
    # Load configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
END
    
    # Generate DH parameters
    if [ ! -f "/etc/nginx/dhparam.pem" ]; then
        openssl dhparam -out /etc/nginx/dhparam.pem 2048
    fi
        # Restart Nginx
    systemctl restart nginx
    echo -e "${GREEN}Nginx optimization completed${NC}"
}

# Function to manage SSL
manage_ssl() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SSL MANAGEMENT                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    domain=$(cat /etc/xray/domain)
    echo -e "Current domain: ${CYAN}$domain${NC}"
    echo -e ""
    echo -e "1) Install new SSL certificate"
    echo -e "2) Renew SSL certificate"
    echo -e "3) View SSL status"
    echo -e "0) Back"
    echo -e ""
    read -p "Select option: " ssl_option
    
    case $ssl_option in
        1)
            systemctl stop nginx
            ~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
            ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
            systemctl start nginx
            echo -e "${GREEN}SSL certificate installed${NC}"
            ;;
        2)
            systemctl stop nginx
            ~/.acme.sh/acme.sh --renew -d $domain --force --ecc
            systemctl start nginx
            echo -e "${GREEN}SSL certificate renewed${NC}"
            ;;
        3)
            if [ -f "/etc/xray/xray.crt" ]; then
                openssl x509 -in /etc/xray/xray.crt -text -noout | grep -A2 "Validity"
            else
                echo -e "${RED}SSL certificate not found${NC}"
            fi
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         NGINX MANAGEMENT              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Install/Update Nginx"
    echo -e " [${GREEN}2${NC}] Configure XRAY"
    echo -e " [${GREEN}3${NC}] Optimize Nginx"
    echo -e " [${GREEN}4${NC}] Manage SSL"
    echo -e " [${GREEN}5${NC}] View Nginx Status"
    echo -e " [${GREEN}6${NC}] View Nginx Logs"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 6 ] : " menu_nginx
        
        case $menu_nginx in
            1) install_nginx ;;
            2) configure_xray ;;
            3) optimize_nginx ;;
            4) manage_ssl ;;
            5)
                clear
                systemctl status nginx
                echo -e ""
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            6)
                clear
                echo -e "${CYAN}Last 50 lines of Nginx error log:${NC}"
                tail -n 50 /var/log/nginx/error.log
                echo -e ""
                read -n 1 -s -r -p "Press any key to continue"
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