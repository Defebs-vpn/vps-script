#!/bin/bash
# Main Installation Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:36:39

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Check root access
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Clear screen
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}         AUTOSCRIPT INSTALLATION         ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Create installation directory
mkdir -p /tmp/installer

# Download installation files
echo -e "${YELLOW}Downloading installation files...${NC}"
cd /tmp/installer
wget -q https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/install-files.zip
unzip -q install-files.zip

# Create necessary directories
mkdir -p /etc/xray
mkdir -p /etc/vps
mkdir -p /usr/local/bin

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
apt-get update
apt-get install -y curl wget unzip jq net-tools vnstat fail2ban

# Install XRAY
echo -e "${YELLOW}Installing XRAY...${NC}"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Copy configuration files
echo -e "${YELLOW}Setting up configuration files...${NC}"
cp -r /tmp/installer/xray/* /etc/xray/
cp -r /tmp/installer/system/* /usr/local/bin/
cp -r /tmp/installer/menu/* /usr/local/bin/
cp -r /tmp/installer/websocket/* /usr/local/bin/

# Set permissions
chmod +x /usr/local/bin/*

# Install Nginx
echo -e "${YELLOW}Installing and configuring Nginx...${NC}"
apt-get install -y nginx
cp /tmp/installer/nginx/nginx.conf /etc/nginx/
cp /tmp/installer/nginx/xray.conf /etc/nginx/conf.d/

# Install acme.sh for SSL
echo -e "${YELLOW}Installing acme.sh...${NC}"
curl https://get.acme.sh | sh

# Setup initial configuration
echo -e "${YELLOW}Setting up initial configuration...${NC}"
read -p "Enter your domain: " domain
echo $domain > /etc/xray/domain

# Get SSL certificate
echo -e "${YELLOW}Getting SSL certificate...${NC}"
systemctl stop nginx
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# Start services
echo -e "${YELLOW}Starting services...${NC}"
systemctl restart nginx
systemctl restart xray
systemctl enable nginx
systemctl enable xray

# Clean up
rm -rf /tmp/installer

# Final configuration
echo -e "${GREEN}Installation completed!${NC}"
echo -e ""
echo -e "Domain      : ${CYAN}$domain${NC}"
echo -e "IP Address  : ${CYAN}$(curl -s ipv4.icanhazip.com)${NC}"
echo -e "Nginx Port  : ${CYAN}80, 443${NC}"
echo -e "XRAY Port   : ${CYAN}443${NC}"
echo -e ""
echo -e "Type ${GREEN}menu${NC} to access VPS menu"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Reboot notification
echo -e "${YELLOW}System will reboot in 5 seconds...${NC}"
sleep 5
reboot