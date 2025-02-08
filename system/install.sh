#!/bin/bash
# Installation Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 06:49:16

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

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}         AUTOSCRIPT INSTALLATION         ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Get domain
echo -e "${CYAN}Please input your domain${NC}"
read -p "Domain/Host: " domain
echo $domain > /etc/xray/domain

# Update system
echo -e "${YELLOW}Updating system...${NC}"
apt-get update
apt-get upgrade -y

# Install required packages
echo -e "${YELLOW}Installing required packages...${NC}"
apt-get install -y curl wget unzip jq net-tools vnstat fail2ban

# Install BBR
echo -e "${YELLOW}Installing BBR...${NC}"
cat > /etc/sysctl.conf <<END
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
END
sysctl -p

# Install certificates
echo -e "${YELLOW}Installing certificates...${NC}"
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# Install XRAY
echo -e "${YELLOW}Installing XRAY...${NC}"
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Install WebSocket
echo -e "${YELLOW}Installing WebSocket...${NC}"
wget -O /usr/local/bin/ws-epro "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/websocket/websocket.sh"
chmod +x /usr/local/bin/ws-epro

# Install menu scripts
echo -e "${YELLOW}Installing menu scripts...${NC}"
cd /usr/local/bin
wget -O menu "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu.sh"
wget -O menu-ssh "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu-ssh.sh"
wget -O menu-vmess "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu-vmess.sh"
wget -O menu-vless "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu-vless.sh"
wget -O menu-trojan "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu-trojan.sh"
wget -O menu-system "https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/menu/menu-system.sh"
chmod +x menu menu-ssh menu-vmess menu-vless menu-trojan menu-system

# Create directories and files
mkdir -p /etc/xray
mkdir -p /etc/vps
touch /etc/xray/vmess.db
touch /etc/xray/vless.db
touch /etc/xray/trojan.db
touch /etc/xray/ssh.db

# Set version
echo "1.0.0" > /etc/vps/version

# Create service
cat > /etc/systemd/system/xray.service <<END
[Unit]
Description=XRAY Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

# Enable and start services
systemctl daemon-reload
systemctl enable xray
systemctl start xray
systemctl enable ws-epro
systemctl start ws-epro

# Final configuration
echo -e "${GREEN}Installation completed!${NC}"
echo -e ""
echo -e "Domain      : ${CYAN}$domain${NC}"
echo -e "IP Address  : ${CYAN}$(curl -s ipv4.icanhazip.com)${NC}"
echo -e "XRAY Port   : ${CYAN}443${NC}"
echo -e "WebSocket   : ${CYAN}80${NC}"
echo -e ""
echo -e "Type ${GREEN}menu${NC} to access VPS menu"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Reboot notification
echo -e "${YELLOW}System will reboot in 5 seconds...${NC}"
sleep 5
reboot