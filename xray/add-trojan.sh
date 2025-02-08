#!/bin/bash
# Add Trojan User
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:38:08

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Function to generate UUID
generate_uuid() {
    uuid=$(cat /proc/sys/kernel/random/uuid)
    echo $uuid
}

# Create Trojan user
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}           ADD TROJAN ACCOUNT             ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Get user input
read -p "Username : " user
if [ -z $user ]; then
    echo -e "${RED}Username cannot be empty${NC}"
    exit 1
fi

# Check existing user
if grep -qw "^### $user" /etc/xray/trojan.db; then
    echo -e "${RED}User $user already exists${NC}"
    exit 1
fi

read -p "Duration (days) : " duration
if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Duration must be a number${NC}"
    exit 1
fi

# Calculate expiry date
exp=$(date -d "+${duration} days" +"%Y-%m-%d")

# Generate password
password=$(generate_uuid)

# Add user to configuration
sed -i "/\"clients\": \[/a \    {\n      \"password\": \"$password\",\n      \"email\": \"$user\"\n    }," /etc/xray/config.json

# Add user info to database
echo "### $user $exp $password" >> /etc/xray/trojan.db

# Restart XRAY service
systemctl restart xray

# Get domain
domain=$(cat /etc/xray/domain)

# Display configuration
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}         TROJAN ACCOUNT DETAILS           ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "Remarks    : ${user}"
echo -e "Domain     : ${domain}"
echo -e "Port       : 443"
echo -e "Password   : ${password}"
echo -e "Path       : /trojan"
echo -e ""
echo -e "Expired On : $exp"
echo -e ""
echo -e "Link : trojan://${password}@${domain}:443?security=tls&type=ws&path=/trojan#${user}"
echo -e ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"