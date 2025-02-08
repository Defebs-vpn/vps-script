#!/bin/bash
# Service Monitoring Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:15:00

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Notification settings
TELEGRAM_BOT_TOKEN=""
TELEGRAM_CHAT_ID=""

# Services to monitor
SERVICES=(
    "ssh"
    "dropbear"
    "stunnel4"
    "xray"
    "nginx"
    "ws-epro"
    "fail2ban"
)

# Function to send telegram notification
send_notification() {
    local message="$1"
    if [ ! -z "$TELEGRAM_BOT_TOKEN" ] && [ ! -z "$TELEGRAM_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
            -d chat_id="$TELEGRAM_CHAT_ID" \
            -d text="$message" \
            -d parse_mode="HTML"
    fi
}

# Function to check service status
check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}Running${NC}"
        return 0
    else
        echo -e "${RED}Stopped${NC}"
        return 1
    fi
}

# Function to restart service
restart_service() {
    local service=$1
    echo -e "${YELLOW}Restarting $service...${NC}"
    systemctl restart $service
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Service $service restarted successfully${NC}"
        send_notification "🔄 Service $service has been restarted on $(hostname)"
    else
        echo -e "${RED}Failed to restart service $service${NC}"
        send_notification "❌ Failed to restart service $service on $(hostname)"
    fi
}

# Function to show service status
show_status() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SERVICE MONITORING             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    for service in "${SERVICES[@]}"; do
        printf "%-15s : %s\n" "$service" "$(check_service $service)"
    done
    
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to monitor services continuously
monitor_services() {
    while true; do
        for service in "${SERVICES[@]}"; do
            if ! systemctl is-active --quiet $service; then
                send_notification "🔴 Service $service is down on $(hostname)"
                restart_service $service
            fi
        done
        sleep 60
    done
}

# Function to configure notifications
configure_notifications() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}       NOTIFICATION SETTINGS            ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    read -p "Enter Telegram Bot Token: " token
    read -p "Enter Telegram Chat ID: " chat_id
    
    # Save settings
    echo "TELEGRAM_BOT_TOKEN=\"$token\"" > /etc/vps/notification.conf
    echo "TELEGRAM_CHAT_ID=\"$chat_id\"" >> /etc/vps/notification.conf
    
    # Test notification
    TELEGRAM_BOT_TOKEN=$token
    TELEGRAM_CHAT_ID=$chat_id
    send_notification "✅ Notification system configured successfully!"
    
    echo -e "${GREEN}Notification settings saved${NC}"
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         SERVICE MANAGEMENT             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Show Service Status"
    echo -e " [${GREEN}2${NC}] Start Monitoring Services"
    echo -e " [${GREEN}3${NC}] Restart All Services"
    echo -e " [${GREEN}4${NC}] Configure Notifications"
    echo -e " [${GREEN}5${NC}] View Service Logs"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    # Load notification settings
    if [ -f "/etc/vps/notification.conf" ]; then
        source /etc/vps/notification.conf
    fi
    
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_service
        
        case $menu_service in
            1) show_status ;;
            2) 
                echo -e "${YELLOW}Starting service monitoring...${NC}"
                monitor_services
                ;;
            3)
                for service in "${SERVICES[@]}"; do
                    restart_service $service
                done
                ;;
            4) configure_notifications ;;
            5)
                clear
                echo -e "${CYAN}Recent Service Logs:${NC}"
                journalctl -n 50 --no-pager
                echo -e ""
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            0) break ;;
            *)
                echo -e "${RED}Please enter an correct number${NC}"
                sleep 1
                ;;
        esac
    done
}

# Run main function
main