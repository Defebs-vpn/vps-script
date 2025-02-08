#!/bin/bash
# Script Update System
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:53:23

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Repository URL
REPO_URL="https://raw.githubusercontent.com/Defebs-vpn/vps-script/main"

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}           UPDATE SCRIPT                  ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Check for updates
echo -e "${CYAN}Checking for updates...${NC}"
wget -q -O /tmp/version "$REPO_URL/version"
current_version=$(cat /etc/vps/version)
latest_version=$(cat /tmp/version)

if [ "$current_version" == "$latest_version" ]; then
    echo -e "${GREEN}You are using the latest version ($current_version)${NC}"
    exit 0
fi

echo -e "Current Version : ${YELLOW}$current_version${NC}"
echo -e "Latest Version  : ${GREEN}$latest_version${NC}"
echo -e ""
echo -e "${YELLOW}Update available! Do you want to update? (y/n)${NC}"
read answer

if [ "$answer" != "${answer#[Yy]}" ]; then
    echo -e "${CYAN}Updating script...${NC}"
    
    # Backup current configuration
    echo -e "${YELLOW}Backing up current configuration...${NC}"
    mkdir -p /tmp/vps-backup
    cp -r /etc/xray /tmp/vps-backup/
    cp -r /etc/vps /tmp/vps-backup/
    
    # Download new version
    echo -e "${YELLOW}Downloading new version...${NC}"
    wget -q -O /tmp/update.zip "$REPO_URL/update.zip"
    
    # Extract and install
    cd /tmp
    unzip -o update.zip
    
    # Copy new files
    cp -r vps-script/* /usr/local/bin/
    cp -r vps-script/xray/* /etc/xray/
    cp -r vps-script/menu/* /usr/local/bin/
    cp -r vps-script/system/* /usr/local/bin/
    
    # Restore configuration
    cp -r /tmp/vps-backup/xray/* /etc/xray/
    cp -r /tmp/vps-backup/vps/* /etc/vps/
    
    # Update version
    echo "$latest_version" > /etc/vps/version
    
    # Clean up
    rm -rf /tmp/update.zip /tmp/vps-script /tmp/vps-backup
    
    # Set permissions
    chmod +x /usr/local/bin/*
    
    echo -e "${GREEN}Update completed!${NC}"
    echo -e "${YELLOW}Please reboot your system to apply changes${NC}"
    echo -e ""
    read -p "Do you want to reboot now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        reboot
    fi
else
    echo -e "${YELLOW}Update cancelled${NC}"
fi