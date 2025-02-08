#!/bin/bash
# Update Script
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
echo -e "${BG}         UPDATE SCRIPT                    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Create temp directory
mkdir -p /tmp/update

# Backup current configuration
echo -e "${YELLOW}Backing up current configuration...${NC}"
cp /etc/xray/config.json /tmp/update/
cp /etc/xray/domain /tmp/update/
cp -r /etc/vps /tmp/update/

# Download latest version
echo -e "${YELLOW}Downloading latest version...${NC}"
cd /tmp/update
wget -q https://raw.githubusercontent.com/Defebs-vpn/vps-script/main/install-files.zip
unzip -q install-files.zip

# Update system scripts
echo -e "${YELLOW}Updating system scripts...${NC}"
cp -r system/* /usr/local/bin/
cp -r menu/* /usr/local/bin/
cp -r websocket/* /usr/local/bin/

# Restore configuration
echo -e "${YELLOW}Restoring configuration...${NC}"
cp /tmp/update/config.json /etc/xray/
cp /tmp/update/domain /etc/xray/
cp -r /tmp/update/vps/* /etc/vps/

# Set permissions
chmod +x /usr/local/bin/*

# Clean up
rm -rf /tmp/update

# Update version number
echo "1.0.1" > /etc/vps/version

# Restart services
echo -e "${YELLOW}Restarting services...${NC}"
systemctl restart nginx
systemctl restart xray

echo -e "${GREEN}Update completed!${NC}"
echo -e "Current version: $(cat /etc/vps/version)"
echo -e ""
echo -e "System will reboot in 5 seconds..."
sleep 5
reboot