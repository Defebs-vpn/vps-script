#!/bin/bash
# SSH VPN Installation Script
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

# Check root access
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

# Install required packages
echo -e "${CYAN}Installing required packages...${NC}"
apt-get update
apt-get install -y openssh-server dropbear stunnel4 fail2ban

# Configure SSH
echo -e "${CYAN}Configuring SSH...${NC}"
sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configure Dropbear
echo -e "${CYAN}Configuring Dropbear...${NC}"
cat > /etc/default/dropbear <<END
NO_START=0
DROPBEAR_PORT=143
DROPBEAR_EXTRA_ARGS="-p 109"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
END

# Configure Stunnel
echo -e "${CYAN}Configuring Stunnel...${NC}"
cat > /etc/stunnel/stunnel.conf <<END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 443
connect = 127.0.0.1:109

[openssh]
accept = 777
connect = 127.0.0.1:22
END

# Generate Stunnel certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=Defebs-VPN/OU=Defebs-VPN/CN=Defebs-VPN"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# Configure Fail2ban
echo -e "${CYAN}Configuring Fail2ban...${NC}"
cat > /etc/fail2ban/jail.local <<END
[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[dropbear]
enabled = true
port = 143,109
filter = dropbear
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
END

# Create SSH Banner
cat > /etc/issue.net <<END
<font color="blue"><b>================================</b></font><br>
<font color="red"><b>         PREMIUM SSH SERVER      </b></font><br>
<font color="blue"><b>================================</b></font><br>
<font color="green"><b>         BY DEFEBS-VPN        </b></font><br>
<font color="blue"><b>================================</b></font><br>
END

# Restart Services
systemctl restart ssh
systemctl restart dropbear
systemctl restart stunnel4
systemctl restart fail2ban

echo -e "${GREEN}SSH VPN Installation Completed!${NC}"
echo -e "SSH Port: 22"
echo -e "Dropbear Ports: 109, 143"
echo -e "Stunnel Ports: 443 (Dropbear), 777 (SSH)"