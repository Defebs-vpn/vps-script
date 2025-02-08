#!/bin/bash
# Backup Menu Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:32:01

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Backup Directory
BACKUP_DIR="/root/backup"

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}           BACKUP MANAGER                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create Backup"
    echo -e " [${GREEN}2${NC}] Restore Backup"
    echo -e " [${GREEN}3${NC}] Auto Backup Settings"
    echo -e " [${GREEN}4${NC}] Backup to Google Drive"
    echo -e " [${GREEN}5${NC}] List Backups"
    echo -e " [${GREEN}6${NC}] Delete Old Backups"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Configure Auto Backup
configure_auto_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         AUTO BACKUP SETTINGS            ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "1) Enable Auto Backup"
    echo -e "2) Disable Auto Backup"
    echo -e "3) Change Backup Schedule"
    echo -e "0) Back"
    echo -e ""
    read -p "Select option : " choice
    
    case $choice in
        1)
            # Create cron job
            cat > /etc/cron.d/auto-backup <<END
0 0 * * * root /usr/local/bin/backup
END
            echo -e "${GREEN}Auto backup enabled${NC}"
            ;;
        2)
            rm -f /etc/cron.d/auto-backup
            echo -e "${YELLOW}Auto backup disabled${NC}"
            ;;
        3)
            echo -e "Current schedule: $(cat /etc/cron.d/auto-backup 2>/dev/null)"
            echo -e "Enter new schedule (in cron format):"
            read -p "Schedule : " schedule
            echo "$schedule root /usr/local/bin/backup" > /etc/cron.d/auto-backup
            echo -e "${GREEN}Backup schedule updated${NC}"
            ;;
        0)
            return
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 6 ] : " menu_backup
        
        case $menu_backup in
            1) backup ;;
            2) restore ;;
            3) configure_auto_backup ;;
            4) backup-gd ;;
            5) ls -lh $BACKUP_DIR ;;
            6) clean-backup ;;
            0) menu ;;
            *)
                echo -e "${RED}Please enter an correct number${NC}"
                sleep 1
            ;;
        esac
    done
}

# Run main function
main