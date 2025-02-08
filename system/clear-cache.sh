#!/bin/bash
# Cache Clearing Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:43:45

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BG}           CLEAR CACHE SYSTEM             ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""

# Get initial memory usage
echo -e "${CYAN}Initial Memory Usage:${NC}"
free -h
echo -e ""

# Clear PageCache
echo -e "${YELLOW}Clearing PageCache...${NC}"
sync; echo 1 > /proc/sys/vm/drop_caches
sleep 1

# Clear dentries and inodes
echo -e "${YELLOW}Clearing dentries and inodes...${NC}"
sync; echo 2 > /proc/sys/vm/drop_caches
sleep 1

# Clear PageCache, dentries and inodes
echo -e "${YELLOW}Clearing PageCache, dentries and inodes...${NC}"
sync; echo 3 > /proc/sys/vm/drop_caches
sleep 1

# Clear swap
echo -e "${YELLOW}Clearing swap space...${NC}"
swapoff -a && swapon -a
sleep 1

# Clear system logs
echo -e "${YELLOW}Clearing system logs...${NC}"
rm -rf /var/log/*
systemctl restart rsyslog

# Clear temp files
echo -e "${YELLOW}Clearing temp files...${NC}"
rm -rf /tmp/*

# Get final memory usage
echo -e ""
echo -e "${CYAN}Final Memory Usage:${NC}"
free -h
echo -e ""
echo -e "${GREEN}Cache cleared successfully!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"