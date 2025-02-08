#!/bin/bash
# Advanced System Monitoring
# Created by: Defebs-vpn
# Current Date: 2025-02-08 04:36:12

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Monitoring Directory
MONITOR_DIR="/var/log/vps-monitor"
mkdir -p $MONITOR_DIR

# Function to monitor CPU temperature
monitor_cpu_temp() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        CPU_TEMP=$(echo "scale=1; $CPU_TEMP/1000" | bc)
        echo $CPU_TEMP
    else
        echo "N/A"
    fi
}

# Function to monitor network interfaces
monitor_network() {
    echo -e "${CYAN}Network Interfaces:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for interface in $(ls /sys/class/net/); do
        if [ $interface != "lo" ]; then
            RX_BYTES=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            TX_BYTES=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            
            RX_MB=$(echo "scale=2; $RX_BYTES/1024/1024" | bc)
            TX_MB=$(echo "scale=2; $TX_BYTES/1024/1024" | bc)
            
            echo -e "Interface: $interface"
            echo -e "↓ Download: ${GREEN}$RX_MB MB${NC}"
            echo -e "↑ Upload  : ${GREEN}$TX_MB MB${NC}"
            echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        fi
    done
}

# Function to monitor disk I/O
monitor_disk_io() {
    echo -e "${CYAN}Disk I/O Statistics:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    iostat -x 1 1 | grep -v "^$" | grep -A 1 "avg-cpu"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to monitor service health
monitor_services() {
    echo -e "${CYAN}Service Health Check:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    services=("ssh" "nginx" "xray" "ws-epro" "stunnel4" "dropbear")
    
    for service in "${services[@]}"; do
        status=$(systemctl is-active $service)
        if [ "$status" == "active" ]; then
            echo -e "$service: ${GREEN}Running${NC}"
        else
            echo -e "$service: ${RED}Stopped${NC}"
        fi
    done
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to monitor user sessions
monitor_sessions() {
    echo -e "${CYAN}Active User Sessions:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # SSH Sessions
    SSH_SESSIONS=$(netstat -tnpa | grep 'ESTABLISHED.*sshd' | wc -l)
    echo -e "SSH Connections   : $SSH_SESSIONS"
    
    # XRAY Sessions
    XRAY_SESSIONS=$(netstat -tnpa | grep 'ESTABLISHED.*xray' | wc -l)
    echo -e "XRAY Connections  : $XRAY_SESSIONS"
    
    # WebSocket Sessions
    WS_SESSIONS=$(netstat -tnpa | grep 'ESTABLISHED.*ws-epro' | wc -l)
    echo -e "WebSocket Sessions: $WS_SESSIONS"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to generate monitoring report
generate_report() {
    REPORT_FILE="$MONITOR_DIR/report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "System Monitoring Report"
        echo "Generated at: $(date)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        echo "CPU Temperature: $(monitor_cpu_temp)°C"
        echo ""
        
        echo "Memory Usage:"
        free -h
        echo ""
        
        echo "Disk Usage:"
        df -h
        echo ""
        
        echo "Network Statistics:"
        netstat -i
        echo ""
        
        echo "Service Status:"
        systemctl status ssh nginx xray ws-epro stunnel4 dropbear --no-pager
        
    } > "$REPORT_FILE"
    
    echo -e "${GREEN}Report generated: $REPORT_FILE${NC}"
}

# Main menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           ADVANCED MONITORING             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "1. Monitor Network Interfaces"
    echo -e "2. Monitor Disk I/O"
    echo -e "3. Monitor Services"
    echo -e "4. Monitor User Sessions"
    echo -e "5. Generate Full Report"
    echo -e "6. Real-time Monitoring"
    echo -e "0. Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Real-time monitoring
realtime_monitor() {
    clear
    echo -e "${YELLOW}Press CTRL+C to stop monitoring${NC}"
    sleep 2
    
    while true; do
        clear
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BG}           REAL-TIME MONITORING           ${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e ""
        
        echo -e "CPU Temperature: $(monitor_cpu_temp)°C"
        echo -e ""
        
        monitor_network
        echo -e ""
        
        monitor_sessions
        echo -e ""
        
        monitor_services
        
        sleep 5
    done
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select an option [0-6]: " choice
        
        case $choice in
            1) monitor_network ;;
            2) monitor_disk_io ;;
            3) monitor_services ;;
            4) monitor_sessions ;;
            5) generate_report ;;
            6) realtime_monitor ;;
            0) break ;;
            *) echo -e "${RED}Invalid option!${NC}" ;;
        esac
        
        read -n 1 -s -r -p "Press any key to continue"
    done
}

main