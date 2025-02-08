#!/bin/bash
# Bandwidth Monitoring Script
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

# Bandwidth log file
BANDWIDTH_LOG="/var/log/bandwidth.log"

# Function to convert bytes to human readable format
convert_size() {
    local size=$1
    local units=('B' 'KB' 'MB' 'GB' 'TB')
    local unit=0
    
    while [ $size -gt 1024 ]; do
        size=$(($size/1024))
        unit=$(($unit+1))
    done
    
    echo "$size ${units[$unit]}"
}

# Function to get network interface usage
get_interface_usage() {
    local interface=$1
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    
    echo "$rx_bytes $tx_bytes"
}

# Function to monitor bandwidth
monitor_bandwidth() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         BANDWIDTH MONITORING           ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Get initial readings
    read rx_old tx_old <<< $(get_interface_usage eth0)
    
    while true; do
        # Get current readings
        read rx_new tx_new <<< $(get_interface_usage eth0)
        
        # Calculate speed
        rx_speed=$((($rx_new-$rx_old)/1024))
        tx_speed=$((($tx_new-$tx_old)/1024))
        
        # Update old values
        rx_old=$rx_new
        tx_old=$tx_new
        
        # Get total usage
        total_rx=$(convert_size $rx_new)
        total_tx=$(convert_size $tx_new)
        
        # Clear screen and display
        clear
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BG}         BANDWIDTH MONITORING           ${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e ""
        echo -e "${CYAN}Current Network Speed:${NC}"
        echo -e "Download: ${GREEN}$rx_speed KB/s${NC}"
        echo -e "Upload  : ${GREEN}$tx_speed KB/s${NC}"
        echo -e ""
        echo -e "${CYAN}Total Usage:${NC}"
        echo -e "Download: ${YELLOW}$total_rx${NC}"
        echo -e "Upload  : ${YELLOW}$total_tx${NC}"
        echo -e ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}Press CTRL+C to stop monitoring${NC}"
        
        # Log bandwidth usage
        echo "$(date '+%Y-%m-%d %H:%M:%S') RX:$total_rx TX:$total_tx" >> $BANDWIDTH_LOG
        
        sleep 1
    done
}

# Main function
main() {
    if ! command -v vnstat &> /dev/null; then
        echo -e "${YELLOW}Installing vnstat...${NC}"
        apt-get install vnstat -y
    fi
    
    monitor_bandwidth
}

# Run main function
main