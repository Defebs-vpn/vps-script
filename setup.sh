#!/bin/bash
# Setup Configuration Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 08:22:24

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
echo -e "${BG}         INITIAL SETUP CONFIGURATION      ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Setup timezone
echo -e "${YELLOW}Setting up timezone...${NC}"
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# Disable IPv6
echo -e "${YELLOW}Disabling IPv6...${NC}"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# Update packages
echo -e "${YELLOW}Updating system packages...${NC}"
apt-get update
apt-get upgrade -y

# Install essential packages
echo -e "${YELLOW}Installing essential packages...${NC}"
apt-get install -y \
    curl \
    wget \
    git \
    zip \
    unzip \
    tar \
    nano \
    net-tools \
    vnstat \
    fail2ban \
    cron \
    socat \
    jq

# Configure SSH
echo -e "${YELLOW}Configuring SSH...${NC}"
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart ssh

# Setup BBR
echo -e "${YELLOW}Setting up BBR...${NC}"
cat > /etc/sysctl.conf <<END
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
END
sysctl -p

# Create necessary directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p /etc/xray
mkdir -p /etc/vps
mkdir -p /var/log/xray

# Set permissions
chmod 777 /var/log/xray

# Setup cronjob for auto reboot
echo -e "${YELLOW}Setting up auto reboot...${NC}"
echo "0 5 * * * root reboot" >> /etc/crontab

# Final configuration
echo -e "${GREEN}Initial setup completed!${NC}"
echo -e ""
echo -e "System will reboot in 5 seconds..."
sleep 5
reboot