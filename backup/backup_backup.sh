#!/bin/bash
# Basic Backup Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 10:50:44

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Backup directory
BACKUP_DIR="/root/backup"
DATE=$(date +%Y%m%d)

# Create backup directory if not exists
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Function to create backup
create_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CREATING BACKUP               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Backup XRAY configuration
    echo -e "${YELLOW}Backing up XRAY configuration...${NC}"
    tar -czf "$BACKUP_DIR/xray-$DATE.tar.gz" /etc/xray
    
    # Backup user database
    echo -e "${YELLOW}Backing up user database...${NC}"
    tar -czf "$BACKUP_DIR/users-$DATE.tar.gz" /etc/passwd /etc/shadow /etc/group
    
    # Create backup info
    echo "Backup created on $(date)" > "$BACKUP_DIR/backup-$DATE.info"
    
    # Create single archive
    cd "$BACKUP_DIR"
    tar -czf "backup-$DATE.tar.gz" \
        xray-$DATE.tar.gz \
        users-$DATE.tar.gz \
        backup-$DATE.info
    
    # Clean up temporary files
    rm -f xray-$DATE.tar.gz users-$DATE.tar.gz backup-$DATE.info
    
    echo -e "${GREEN}Backup completed!${NC}"
    echo -e "Backup file: ${YELLOW}$BACKUP_DIR/backup-$DATE.tar.gz${NC}"
}

# Function to restore backup
restore_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         RESTORE BACKUP                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # List available backups
    echo -e "${CYAN}Available backups:${NC}"
    ls -1 "$BACKUP_DIR" | grep "backup-.*tar.gz" | nl
    
    read -p "Select backup number (0 to cancel): " number
    [ "$number" = "0" ] && return
    
    backup_file=$(ls -1 "$BACKUP_DIR" | grep "backup-.*tar.gz" | sed -n "${number}p")
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Invalid backup selection${NC}"
        return
    fi
    
    # Restore backup
    cd "$BACKUP_DIR"
    tar -xzf "$backup_file"
    tar -xzf xray-*.tar.gz -C /
    tar -xzf users-*.tar.gz -C /
    
    # Clean up
    rm -f xray-*.tar.gz users-*.tar.gz backup-*.info
    
    echo -e "${GREEN}Backup restored successfully!${NC}"
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         BACKUP MANAGER                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create Backup"
    echo -e " [${GREEN}2${NC}] Restore Backup"
    echo -e " [${GREEN}3${NC}] List Backups"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 3 ] : " menu_backup
        case $menu_backup in
            1) create_backup ;;
            2) restore_backup ;;
            3) 
                ls -lh "$BACKUP_DIR" | grep "backup-"
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            0) break ;;
            *) echo -e "${RED}Please enter an correct number${NC}" ;;
        esac
    done
}

# Run main function
main