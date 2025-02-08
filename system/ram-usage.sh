#!/bin/bash
# RAM Usage Monitor
# Created by: Defebs-vpn
# Created at: 2025-02-07 14:56:51

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get RAM information
TOTAL_RAM=$(free -m | grep Mem | awk '{print $2}')
USED_RAM=$(free -m | grep Mem | awk '{print $3}')
FREE_RAM=$(free -m | grep Mem | awk '{print $4}')
SHARED_RAM=$(free -m | grep Mem | awk '{print $5}')
CACHE_RAM=$(free -m | grep Mem | awk '{print $6}')
AVAILABLE_RAM=$(free -m | grep Mem | awk '{print $7}')

# Calculate RAM usage percentage
RAM_USAGE=$(awk "BEGIN {printf \"%.2f\", ${USED_RAM}/${TOTAL_RAM}*100}")

# Display RAM information with colorful bar
function display_ram_bar() {
    local usage=$1
    local width=50
    local filled=$(awk "BEGIN {printf \"%.0f\", $usage/100*$width}")
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "#"; done
    for ((i=0; i<empty; i++)); do printf "-"; done
    printf "] %.2f%%\n" $usage
}

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}            RAM Usage Monitor              ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo -e "Total RAM    : ${GREEN}${TOTAL_RAM} MB${NC}"
echo -e "Used RAM     : ${YELLOW}${USED_RAM} MB${NC}"
echo -e "Free RAM     : ${GREEN}${FREE_RAM} MB${NC}"
echo -e "Shared RAM   : ${BLUE}${SHARED_RAM} MB${NC}"
echo -e "Cache RAM    : ${BLUE}${CACHE_RAM} MB${NC}"
echo -e "Available RAM: ${GREEN}${AVAILABLE_RAM} MB${NC}"
echo -e ""
echo -e "RAM Usage:"
echo -ne "${YELLOW}"
display_ram_bar $RAM_USAGE
echo -ne "${NC}"
echo -e ""

# Show top processes by RAM usage
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}     Top 5 Processes by RAM Usage         ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
ps aux --sort=-%mem | head -n 6 | awk '
BEGIN {printf "%-20s %-10s %-10s %s\n", "USER", "PID", "RAM%", "COMMAND"}
NR>1 {printf "%-20s %-10s %-10.2f %s\n", $1, $2, $4, $11}'
echo -e ""

# Check if RAM usage is critical
if (( $(echo "$RAM_USAGE > 90" | bc -l) )); then
    echo -e "${RED}WARNING: RAM usage is critical!${NC}"
    echo -e "Consider clearing cache or checking for memory leaks."
    echo -e ""
    echo -e "To clear cache, run: ${YELLOW}sudo sh /usr/bin/clear-cache${NC}"
fi

# Memory management recommendations
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}       Memory Management Tips             ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
if (( $(echo "$CACHE_RAM > 1024" | bc -l) )); then
    echo -e "• High cache detected. Consider clearing if needed."
fi
if (( $(echo "$RAM_USAGE > 80" | bc -l) )); then
    echo -e "• High memory usage. Consider optimizing services."
fi
if [ $AVAILABLE_RAM -lt 1024 ]; then
    echo -e "• Low available memory. Monitor system performance."
fi

# Add monitoring to log file
LOG_FILE="/var/log/ram-usage.log"
echo "$(date '+%Y-%m-%d %H:%M:%S') - RAM Usage: ${RAM_USAGE}% (Used: ${USED_RAM}MB / Total: ${TOTAL_RAM}MB)" >> $LOG_FILE