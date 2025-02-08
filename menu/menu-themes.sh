#!/bin/bash
# Menu Theme Customization
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

# Theme configurations
THEME_DIR="/etc/vps/themes"
CURRENT_THEME="/etc/vps/current_theme"

# Create theme directory if not exist
mkdir -p $THEME_DIR

# Theme Options
themes=(
    "Classic Dark"
    "Light Mode"
    "Ocean Blue"
    "Forest Green"
    "Sunset Orange"
    "Custom"
)

# Theme Color Schemes
declare -A theme_colors
theme_colors["Classic Dark"]="dark.theme"
theme_colors["Light Mode"]="light.theme"
theme_colors["Ocean Blue"]="ocean.theme"
theme_colors["Forest Green"]="forest.theme"
theme_colors["Sunset Orange"]="sunset.theme"

# Function to apply theme
apply_theme() {
    local theme=$1
    case $theme in
        "Classic Dark")
            echo "export BG_COLOR='#000000'" > $CURRENT_THEME
            echo "export TEXT_COLOR='#FFFFFF'" >> $CURRENT_THEME
            echo "export ACCENT_COLOR='#00FF00'" >> $CURRENT_THEME
            ;;
        "Light Mode")
            echo "export BG_COLOR='#FFFFFF'" > $CURRENT_THEME
            echo "export TEXT_COLOR='#000000'" >> $CURRENT_THEME
            echo "export ACCENT_COLOR='#0000FF'" >> $CURRENT_THEME
            ;;
        "Ocean Blue")
            echo "export BG_COLOR='#1a4b77'" > $CURRENT_THEME
            echo "export TEXT_COLOR='#e0f0ff'" >> $CURRENT_THEME
            echo "export ACCENT_COLOR='#00ccff'" >> $CURRENT_THEME
            ;;
        # Add more themes here
    esac
}

# Display menu
show_themes() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BG}              THEME SETTINGS               ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
    
    for i in "${!themes[@]}"; do
        echo -e "$((i+1)). ${themes[$i]}"
    done
    
    echo -e "0. Back to Main Menu"
    echo -e ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e ""
}

# Main function
main() {
    while true; do
        show_themes
        read -p "Select theme [0-${#themes[@]}]: " choice
        
        case $choice in
            0)
                break
                ;;
            [1-${#themes[@]}])
                selected_theme=${themes[$((choice-1))]}
                apply_theme "$selected_theme"
                echo -e "${GREEN}Theme applied successfully!${NC}"
                sleep 2
                ;;
            *)
                echo -e "${RED}Invalid option!${NC}"
                sleep 2
                ;;
        esac
    done
}

main