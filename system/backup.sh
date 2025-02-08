#!/bin/bash
# Backup Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 07:18:04

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
    
    # Backup SSH configuration
    echo -e "${YELLOW}Backing up SSH configuration...${NC}"
    tar -czf "$BACKUP_DIR/ssh-$DATE.tar.gz" /etc/ssh
    
    # Backup system configuration
    echo -e "${YELLOW}Backing up system configuration...${NC}"
    tar -czf "$BACKUP_DIR/system-$DATE.tar.gz" /etc/vps
    
    # Create backup info
    echo "Backup created on $(date)" > "$BACKUP_DIR/backup-$DATE.info"
    echo "Server IP: $(curl -s ipv4.icanhazip.com)" >> "$BACKUP_DIR/backup-$DATE.info"
    echo "Domain: $(cat /etc/xray/domain)" >> "$BACKUP_DIR/backup-$DATE.info"
    
    # Create single archive
    cd "$BACKUP_DIR"
    tar -czf "backup-$DATE.tar.gz" \
        xray-$DATE.tar.gz \
        users-$DATE.tar.gz \
        ssh-$DATE.tar.gz \
        system-$DATE.tar.gz \
        backup-$DATE.info
    
    # Clean up temporary files
    rm -f xray-$DATE.tar.gz users-$DATE.tar.gz ssh-$DATE.tar.gz system-$DATE.tar.gz backup-$DATE.info
    
    echo -e ""
    echo -e "${GREEN}Backup completed!${NC}"
    echo -e "Backup file: ${YELLOW}$BACKUP_DIR/backup-$DATE.tar.gz${NC}"
    echo -e ""
    
    # Ask for Google Drive upload
    read -p "Do you want to upload backup to Google Drive? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        upload_to_gdrive "backup-$DATE.tar.gz"
    fi
}

# Function to upload to Google Drive
upload_to_gdrive() {
    local file="$1"
    if ! command -v rclone &> /dev/null; then
        echo -e "${YELLOW}Installing rclone...${NC}"
        curl https://rclone.org/install.sh | bash
        
        echo -e "${YELLOW}Configuring rclone...${NC}"
        echo -e "Please configure rclone for Google Drive access"
        rclone config
    fi
    
    if rclone lsd gdrive: &>/dev/null; then
        echo -e "${YELLOW}Uploading to Google Drive...${NC}"
        rclone copy "$BACKUP_DIR/$file" gdrive:VPS-Backup/
        echo -e "${GREEN}Upload completed!${NC}"
    else
        echo -e "${RED}Failed to access Google Drive. Please configure rclone first${NC}"
    fi
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
    echo -e ""
    
    read -p "Select backup number to restore (0 to cancel): " number
    if [ "$number" = "0" ]; then
        return
    fi
    
    backup_file=$(ls -1 "$BACKUP_DIR" | grep "backup-.*tar.gz" | sed -n "${number}p")
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Invalid backup selection${NC}"
        return
    fi
    
    echo -e "${YELLOW}Restoring backup...${NC}"
    cd "$BACKUP_DIR"
    
    # Extract main archive
    tar -xzf "$backup_file"
    
    # Restore XRAY configuration
    tar -xzf xray-*.tar.gz -C /
    
    # Restore user database
    tar -xzf users-*.tar.gz -C /
    
    # Restore SSH configuration
    tar -xzf ssh-*.tar.gz -C /
    
    # Restore system configuration
    tar -xzf system-*.tar.gz -C /
    
    # Clean up
    rm -f xray-*.tar.gz users-*.tar.gz ssh-*.tar.gz system-*.tar.gz backup-*.info
    
    # Restart services
    systemctl restart ssh xray
    
    echo -e "${GREEN}Backup restored successfully!${NC}"
    echo -e "${YELLOW}System will reboot in 5 seconds...${NC}"
    sleep 5
    reboot
}

# Function to clean old backups
clean_backups() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         CLEAN OLD BACKUPS             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Keep only last 5 backups
    cd "$BACKUP_DIR"
    ls -1t backup-*.tar.gz | tail -n +6 | xargs -r rm
    
    echo -e "${GREEN}Old backups cleaned${NC}"
}

# Show menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         BACKUP MANAGER                ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Create Backup"
    echo -e " [${GREEN}2${NC}] Restore Backup"
    echo -e " [${GREEN}3${NC}] Upload to Google Drive"
    echo -e " [${GREEN}4${NC}] Clean Old Backups"
    echo -e " [${GREEN}5${NC}] Configure Google Drive"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 5 ] : " menu_backup
        
        case $menu_backup in
            1) create_backup ;;
            2) restore_backup ;;
            3)
                read -p "Enter backup file name: " file
                upload_to_gdrive "$file"
                ;;
            4) clean_backups ;;
            5) rclone config ;;
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