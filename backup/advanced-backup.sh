#!/bin/bash
# Advanced Backup Script
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

# Backup configuration
BACKUP_DIR="/root/backup"
REMOTE_DIR="gdrive:VPS-Backup"
MAX_BACKUPS=5
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to upload to Google Drive
upload_to_gdrive() {
    if ! command -v rclone &>/dev/null; then
        echo -e "${YELLOW}Installing rclone...${NC}"
        curl https://rclone.org/install.sh | bash
        echo -e "${YELLOW}Please configure rclone for Google Drive${NC}"
        rclone config
    fi
    
    if rclone lsd gdrive: &>/dev/null; then
        echo -e "${YELLOW}Uploading to Google Drive...${NC}"
        rclone copy "$1" "$REMOTE_DIR/"
        echo -e "${GREEN}Upload completed!${NC}"
    else
        echo -e "${RED}Failed to access Google Drive${NC}"
    fi
}

# Function to create encrypted backup
create_encrypted_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         ADVANCED BACKUP                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Generate encryption key
    KEY_FILE="$BACKUP_DIR/backup.key"
    if [ ! -f "$KEY_FILE" ]; then
        openssl rand -base64 32 > "$KEY_FILE"
    fi
    
    # Create backup archive
    echo -e "${YELLOW}Creating backup archive...${NC}"
    tar -czf - \
        /etc/xray \
        /etc/nginx \
        /etc/passwd \
        /etc/shadow \
        /etc/group \
        /etc/vps \
        /root/log \
        | openssl enc -aes-256-cbc -salt -pass file:"$KEY_FILE" \
        > "$BACKUP_DIR/backup-$DATE.enc"
    
    # Create backup info
    cat > "$BACKUP_DIR/backup-$DATE.info" <<EOF
Backup Information:
Date: $(date)
Server: $(hostname)
IP: $(curl -s ipv4.icanhazip.com)
Files: XRAY, Nginx, Users, VPS Config, Logs
EOF
    
    # Upload to Google Drive
    read -p "Upload to Google Drive? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        upload_to_gdrive "$BACKUP_DIR/backup-$DATE.enc"
        upload_to_gdrive "$BACKUP_DIR/backup-$DATE.info"
    fi
    
    # Cleanup old backups
    cd "$BACKUP_DIR"
    ls -1t backup-*.enc | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    ls -1t backup-*.info | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm
    
    echo -e "${GREEN}Advanced backup completed!${NC}"
}

# Function to restore encrypted backup
restore_encrypted_backup() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         RESTORE ADVANCED BACKUP        ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # List available backups
    echo -e "${CYAN}Available encrypted backups:${NC}"
    ls -1 "$BACKUP_DIR" | grep "backup-.*enc" | nl
    
    read -p "Select backup number (0 to cancel): " number
    [ "$number" = "0" ] && return
    
    backup_file=$(ls -1 "$BACKUP_DIR" | grep "backup-.*enc" | sed -n "${number}p")
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Invalid backup selection${NC}"
        return
    fi
    
    # Restore backup
    echo -e "${YELLOW}Restoring encrypted backup...${NC}"
    openssl enc -aes-256-cbc -d -pass file:"$KEY_FILE" \
        -in "$BACKUP_DIR/$backup_file" | tar -xzf - -C /
    
    echo -e "${GREEN}Backup restored successfully!${NC}"
    echo -e "${YELLOW}System will reboot in 5 seconds...${NC}"
    sleep 5
    reboot
}

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         ADVANCED BACKUP MANAGER        ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create Encrypted Backup"
    echo -e " [${GREEN}2${NC}] Restore Encrypted Backup"
    echo -e " [${GREEN}3${NC}] Configure Google Drive"
    echo -e " [${GREEN}4${NC}] List Remote Backups"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 4 ] : " menu_backup
        case $menu_backup in
            1) create_encrypted_backup ;;
            2) restore_encrypted_backup ;;
            3) rclone config ;;
            4) 
                rclone ls "$REMOTE_DIR"
                read -n 1 -s -r -p "Press any key to continue"
                ;;
            0) break ;;
            *) echo -e "${RED}Please enter an correct number${NC}" ;;
        esac
    done
}

# Run main function
main