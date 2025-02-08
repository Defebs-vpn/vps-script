#!/bin/bash
# Delete VMESS User
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:09:56

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Display menu
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}          DELETE VMESS ACCOUNT            ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Get user list
echo -e "${CYAN}Current Users:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep "^### " /etc/xray/vmess.db | cut -d ' ' -f 2-3 | nl -s ') '
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Get user input
read -p "Select user number to delete (Ctrl+C to cancel): " number
if [[ ! $number =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Please input numbers only${NC}"
    exit 1
fi

# Get username from selection
user=$(grep "^### " /etc/xray/vmess.db | cut -d ' ' -f 2 | sed -n "${number}"p)
if [ -z $user ]; then
    echo -e "${RED}User does not exist${NC}"
    exit 1
fi

# Get UUID
uuid=$(grep "^### $user" /etc/xray/vmess.db | cut -d ' ' -f 4)

# Remove from configuration
sed -i "/\"id\": \"$uuid\"/,+3d" /etc/xray/vmess.json
sed -i "/^### $user/d" /etc/xray/vmess.db

# Restart XRAY service
systemctl restart xray

# Display success message
echo -e ""
echo -e "${GREEN}VMESS Account ${YELLOW}$user ${GREEN}has been deleted${NC}"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"