#!/bin/bash
# Add VMESS User
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

# Get configuration
source /etc/xray/config.json

# Function to generate UUID
generate_uuid() {
    uuid=$(cat /proc/sys/kernel/random/uuid)
    echo $uuid
}

# Function to create VMESS user
create_vmess_user() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           ADD VMESS ACCOUNT              ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Get user input
    read -p "Username : " user
    if [ -z $user ]; then
        echo -e "${RED}Username cannot be empty${NC}"
        return 1
    fi
    
    # Check existing user
    if grep -qw "^### $user" /etc/xray/vmess.json; then
        echo -e "${RED}User $user already exists${NC}"
        return 1
    fi
    
    # Get duration
    read -p "Duration (days) : " duration
    if ! [[ "$duration" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Duration must be a number${NC}"
        return 1
    fi
    
    # Calculate expiry date
    exp=$(date -d "+${duration} days" +"%Y-%m-%d")
    
    # Generate UUID
    uuid=$(generate_uuid)
    
    # Add user to configuration
    sed -i "/\"clients\": \[/a \    {\n      \"id\": \"$uuid\",\n      \"alterId\": 0,\n      \"email\": \"$user\"\n    }," /etc/xray/vmess.json
    
    # Add user info to database
    echo "### $user $exp $uuid" >> /etc/xray/vmess.db
    
    # Restart XRAY service
    systemctl restart xray
    
    # Generate configuration
    domain=$(cat /etc/xray/domain)
    port="443"
    encryption="auto"
    
    vmess_config=$(cat <<EOF
{
  "v": "2",
  "ps": "$user",
  "add": "$domain",
  "port": "$port",
  "id": "$uuid",
  "aid": "0",
  "net": "ws",
  "path": "/vmess",
  "type": "none",
  "host": "$domain",
  "tls": "tls"
}
EOF
)

    # Convert to base64
    vmess_base64=$(echo $vmess_config | base64 -w 0)
    
    # Display configuration
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         VMESS ACCOUNT DETAILS            ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "Remarks    : ${user}"
    echo -e "Domain     : ${domain}"
    echo -e "Port       : ${port}"
    echo -e "UUID       : ${uuid}"
    echo -e "Encryption : ${encryption}"
    echo -e "Network    : ws"
    echo -e "Path       : /vmess"
    echo -e "TLS        : tls"
    echo -e ""
    echo -e "Expired On : $exp"
    echo -e ""
    echo -e "VMESS Link : vmess://${vmess_base64}"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Run main function
create_vmess_user