#!/bin/bash
# WebSocket Service Installer
# By: Defebs-vpn
# Current Date: 2025-02-07 15:43:55

# Create systemd service file
cat > /etc/systemd/system/ws-epro.service <<EOL
[Unit]
Description=WebSocket Proxy Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin
ExecStart=/usr/bin/python3 /usr/local/bin/ws-epro.py --port 80
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOL

# Enable and start service
systemctl daemon-reload
systemctl enable ws-epro
systemctl start ws-epro

echo "WebSocket service installed and started"