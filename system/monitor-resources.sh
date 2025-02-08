#!/bin/bash
# Resource Monitoring Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:24:16

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Monitoring log
LOG_FILE="/var/log/vps-monitor.log"

# Function to get CPU usage
get_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo $cpu_usage
}

# Function to get Memory usage
get_memory_usage() {
    memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
    echo $memory_usage
}

# Function to get Disk usage
get_disk_usage() {
    disk_usage=$(df -h / | awk 'NR==2{print $5}' | sed 's/%//g')
    echo $disk_usage
}

# Function to get Network usage
get_network_usage() {
    network_rx=$(ifconfig | grep -A 1 'eth0' | tail -1 | awk '{print $2}')
    network_tx=$(ifconfig | grep -A 1 'eth0' | tail -1 | awk '{print $6}')
    
    echo "$network_rx $network_tx"
}

# Function to monitor services
monitor_services() {
    services=("ssh" "dropbear" "stunnel4" "xray" "nginx")
    statuses=""
    
    for service in "${services[@]}"; do
        status=$(systemctl is-active $service)
        if [ "$status" == "active" ]; then
            statuses+="${GREEN}$service: Running${NC}\n"
        else
            statuses+="${RED}$service: Stopped${NC}\n"
        fi
    done
    
    echo -e "$statuses"
}

# Function to display resource usage
display_usage() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         RESOURCE MONITORING             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Get resource usage
    cpu=$(get_cpu_usage)
    memory=$(get_memory_usage)
    disk=$(get_disk_usage)
    read network_rx network_tx <<< $(get_network_usage)
    
    # Display information
    echo -e "${CYAN}CPU Usage    : ${NC}${cpu}%"
    echo -e "${CYAN}Memory Usage : ${NC}${memory}%"
    echo -e "${CYAN}Disk Usage   : ${NC}${disk}%"
    echo -e "${CYAN}Network RX   : ${NC}$(($network_rx/1024/1024)) MB"
    echo -e "${CYAN}Network TX   : ${NC}$(($network_tx/1024/1024)) MB"
    echo -e ""
    echo -e "${CYAN}Service Status:${NC}"
    echo -e "$(monitor_services)"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Log information
    echo "$(date '+%Y-%m-%d %H:%M:%S') CPU:${cpu}% MEM:${memory}% DISK:${disk}%" >> $LOG_FILE
}

# Main function
main() {
    while true; do
        display_usage
        echo -e "${YELLOW}Auto-refresh every 5 seconds. Press CTRL+C to exit.${NC}"
        sleep 5
    done
}

# Run main function
main