#!/bin/bash
# Multi Login Kill Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:53:23

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Configuration file
CONFIG_FILE="/etc/vps/auto-kill.conf"

# Create config if not exists
if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p /etc/vps
    echo "ENABLED=false" > $CONFIG_FILE
    echo "MAX_LOGIN=2" >> $CONFIG_FILE
fi

# Load configuration
source $CONFIG_FILE

# Show Menu
show_menu() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         AUTO KILL MULTI LOGIN          ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e " Status: $([[ $ENABLED == "true" ]] && echo "${GREEN}Enabled${NC}" || echo "${RED}Disabled${NC}")"
    echo -e " Max Login: ${YELLOW}$MAX_LOGIN${NC}"
    echo -e ""
    echo -e " [${GREEN}1${NC}] Enable Auto Kill"
    echo -e " [${GREEN}2${NC}] Disable Auto Kill"
    echo -e " [${GREEN}3${NC}] Set Max Login"
    echo -e " [${GREEN}4${NC}] View Current Settings"
    echo -e " [${GREEN}0${NC}] Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to enable auto kill
enable_auto_kill() {
    sed -i 's/ENABLED=.*/ENABLED=true/' $CONFIG_FILE
    
    # Create auto kill script
    cat > /usr/local/bin/auto-kill <<END
#!/bin/bash
# Auto Kill Multi Login
# Created by: Defebs-vpn

source /etc/vps/auto-kill.conf

if [ "\$ENABLED" != "true" ]; then
    exit 0
fi

# Check SSH users
data=( \`cat /etc/passwd | grep '/home/' | cut -d ':' -f 1\` )
for user in "\${data[@]}"
do
    exp=\$(chage -l \$user | grep "Account expires" | awk -F": " '{print \$2}')
    if [[ \$exp == "never" ]]; then
        continue
    fi
    
    login=\$(ps aux | grep -w "\$user" | grep -v grep | wc -l)
    if [ \$login -gt \$MAX_LOGIN ]; then
        ps aux | grep -w \$user | grep -v grep | awk '{print \$2}' | xargs kill -9 >/dev/null 2>&1
        echo "\$(date '+%Y-%m-%d %H:%M:%S') - Killed \$user processes (\$login instances)" >> /var/log/auto-kill.log
    fi
done

# Check XRAY users
for type in vmess vless trojan; do
    if [ -f "/etc/xray/\${type}.db" ]; then
        data=( \`cat /etc/xray/\${type}.db | grep '^###' | cut -d ' ' -f 2\` )
        for user in "\${data[@]}"
        do
            login=\$(netstat -anp | grep ESTABLISHED | grep tcp6 | grep xray | grep -w 443 | awk '{print \$5}' | cut -d: -f1 | sort | uniq -c | grep -w \$user | awk '{print \$1}')
            if [ -z "\$login" ]; then
                login=0
            fi
            if [ \$login -gt \$MAX_LOGIN ]; then
                systemctl restart xray
                echo "\$(date '+%Y-%m-%d %H:%M:%S') - Restarted XRAY due to \$user excess login (\$login instances)" >> /var/log/auto-kill.log
                break
            fi
        done
    fi
done
END
    
    chmod +x /usr/local/bin/auto-kill
    
    # Create cron job
    echo "*/1 * * * * root /usr/local/bin/auto-kill" > /etc/cron.d/auto-kill
    
    echo -e "${GREEN}Auto Kill has been enabled${NC}"
}

# Function to disable auto kill
disable_auto_kill() {
    sed -i 's/ENABLED=.*/ENABLED=false/' $CONFIG_FILE
    rm -f /etc/cron.d/auto-kill
    echo -e "${YELLOW}Auto Kill has been disabled${NC}"
}

# Function to set max login
set_max_login() {
    read -p "Enter maximum login allowed: " max
    if ! [[ "$max" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Please input numbers only${NC}"
        return
    fi
    
    sed -i "s/MAX_LOGIN=.*/MAX_LOGIN=$max/" $CONFIG_FILE
    echo -e "${GREEN}Max login has been set to: $max${NC}"
}

# Function to view current settings
view_settings() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}         AUTO KILL SETTINGS             ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    echo -e "Status     : $([[ $ENABLED == "true" ]] && echo "${GREEN}Enabled${NC}" || echo "${RED}Disabled${NC}")"
    echo -e "Max Login  : ${YELLOW}$MAX_LOGIN${NC}"
    echo -e ""
    if [ -f "/var/log/auto-kill.log" ]; then
        echo -e "${CYAN}Recent Auto Kill Logs:${NC}"
        tail -n 5 /var/log/auto-kill.log
    fi
    echo -e ""
    read -n 1 -s -r -p "Press any key to continue"
}

# Main function
main() {
    while true; do
        show_menu
        read -p "Select From Options [ 0 - 4 ] : " menu_kill
        
        case $menu_kill in
            1) enable_auto_kill ;;
            2) disable_auto_kill ;;
            3) set_max_login ;;
            4) view_settings ;;
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