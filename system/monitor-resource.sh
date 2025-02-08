# System Resource Monitoring
function monitor_resources() {
    # Get Load Average
    LOAD_1=$(cat /proc/loadavg | awk '{print $1}')
    LOAD_5=$(cat /proc/loadavg | awk '{print $2}')
    LOAD_15=$(cat /proc/loadavg | awk '{print $3}')
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}             RESOURCE MONITORING             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "${CYAN}Load Average:${NC}"
    echo -e " ➣ 1 Minute    : $LOAD_1"
    echo -e " ➣ 5 Minutes   : $LOAD_5"
    echo -e " ➣ 15 Minutes  : $LOAD_15"
    echo -e ""
    
    # Network Statistics
    RX_BYTES=$(ifconfig | grep -A 1 eth0 | tail -1 | awk '{print $2}')
    TX_BYTES=$(ifconfig | grep -A 1 eth0 | tail -1 | awk '{print $6}')
    
    echo -e "${CYAN}Network Statistics:${NC}"
    echo -e " ➣ Download    : $(($RX_BYTES/1024/1024)) MB"
    echo -e " ➣ Upload      : $(($TX_BYTES/1024/1024)) MB"
    echo -e ""
    
    # Process Statistics
    TOTAL_PROCS=$(ps aux | wc -l)
    USER_PROCS=$(ps -U root -u root -N | wc -l)
    
    echo -e "${CYAN}Process Statistics:${NC}"
    echo -e " ➣ Total       : $TOTAL_PROCS processes"
    echo -e " ➣ User        : $USER_PROCS processes"
    echo -e ""
}

# Security Information
function security_info() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}             SECURITY INFORMATION            ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    # Failed SSH Attempts
    FAILED_SSH=$(grep "Failed password" /var/log/auth.log | wc -l)
    BLOCKED_IPS=$(iptables -L INPUT -n | grep DROP | wc -l)
    
    echo -e "${CYAN}Security Stats:${NC}"
    echo -e " ➣ Failed SSH  : $FAILED_SSH attempts"
    echo -e " ➣ Blocked IPs : $BLOCKED_IPS addresses"
    echo -e ""
    
    # Last Logins
    echo -e "${CYAN}Last 5 Logins:${NC}"
    last -5 | head -n 5
    echo -e ""
}

# Backup Status
function backup_status() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}               BACKUP STATUS                 ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    LAST_BACKUP=$(ls -lt /root/backup/ | grep backup_ | head -n 1 | awk '{print $6, $7, $8}')
    BACKUP_SIZE=$(du -sh /root/backup/ | awk '{print $1}')
    
    echo -e "${CYAN}Backup Information:${NC}"
    echo -e " ➣ Last Backup : $LAST_BACKUP"
    echo -e " ➣ Backup Size : $BACKUP_SIZE"
    echo -e ""
}

# Display Everything
clear
echo -e "$banner"
monitor_resources
security_info
backup_status

# Save to log file
echo "$(date '+%Y-%m-%d %H:%M:%S') - System Check Completed" >> $LOG_FILE