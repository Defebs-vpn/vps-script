#!/bin/bash
# WebSocket Installation Script
# Created by: Defebs-vpn
# Current Date: 2025-02-08 05:38:08

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BG='\E[44;1;39m'

# Install Requirements
echo -e "${CYAN}Installing WebSocket requirements...${NC}"
apt-get update
apt-get install -y python3 python3-pip
pip3 install websockets asyncio

# Create WebSocket Service
cat > /usr/local/bin/ws-epro <<END
#!/usr/bin/python3
import socket
import threading
import os
import json
import time
import sys
import asyncio
import websockets
import ssl
import logging
from datetime import datetime

# Configuration
LISTEN_PORT = 80
SSH_PORT = 22
MAX_CONNECTIONS = 1000
BUFFER_SIZE = 65535

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("/var/log/ws-epro.log"),
        logging.StreamHandler()
    ]
)

class ConnectionStats:
    def __init__(self):
        self.bytes_in = 0
        self.bytes_out = 0
        self.connected_at = time.time()
        self.last_activity = time.time()

    def update(self, bytes_in=0, bytes_out=0):
        self.bytes_in += bytes_in
        self.bytes_out += bytes_out
        self.last_activity = time.time()

class WebSocketProxy:
    def __init__(self):
        self.connections = {}
        self.stats = {
            'total_connections': 0,
            'active_connections': 0,
            'total_bytes_in': 0,
            'total_bytes_out': 0,
            'start_time': time.time()
        }

    async def handle_connection(self, websocket, path):
        client_address = websocket.remote_address
        connection_id = f"{client_address[0]}:{client_address[1]}"

        try:
            # Create SSH connection
            ssh_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ssh_sock.connect(('127.0.0.1', SSH_PORT))

            # Update statistics
            self.stats['total_connections'] += 1
            self.stats['active_connections'] += 1
            self.connections[connection_id] = ConnectionStats()

            logging.info(f"New connection from {connection_id}")

            async def forward_ws_to_ssh():
                try:
                    while True:
                        data = await websocket.recv()
                        if not data:
                            break
                        ssh_sock.send(data)
                        self.connections[connection_id].update(bytes_in=len(data))
                        self.stats['total_bytes_in'] += len(data)
                except:
                    pass

            async def forward_ssh_to_ws():
                try:
                    while True:
                        data = ssh_sock.recv(BUFFER_SIZE)
                        if not data:
                            break
                        await websocket.send(data)
                        self.connections[connection_id].update(bytes_out=len(data))
                        self.stats['total_bytes_out'] += len(data)
                except:
                    pass

            await asyncio.gather(
                forward_ws_to_ssh(),
                forward_ssh_to_ws()
            )

        except Exception as e:
            logging.error(f"Error handling connection {connection_id}: {str(e)}")

        finally:
            ssh_sock.close()
            if connection_id in self.connections:
                del self.connections[connection_id]
            self.stats['active_connections'] -= 1
            logging.info(f"Connection closed: {connection_id}")

    async def start_server(self):
        async with websockets.serve(
            self.handle_connection,
            "0.0.0.0",
            LISTEN_PORT,
            max_size=None,
            read_limit=2**20,
            write_limit=2**20
        ) as server:
            logging.info(f"WebSocket server started on port {LISTEN_PORT}")
            await asyncio.Future()  # run forever

if __name__ == "__main__":
    proxy = WebSocketProxy()
    try:
        asyncio.run(proxy.start_server())
    except KeyboardInterrupt:
        logging.info("Server shutting down...")
    except Exception as e:
        logging.error(f"Fatal error: {str(e)}")
        sys.exit(1)
END

# Make executable
chmod +x /usr/local/bin/ws-epro

# Create Service
cat > /etc/systemd/system/ws-epro.service <<END
[Unit]
Description=WebSocket Proxy Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/ws-epro
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
END

# Enable and start service
systemctl daemon-reload
systemctl enable ws-epro
systemctl start ws-epro

echo -e "${GREEN}WebSocket Installation Completed!${NC}"
echo -e "WebSocket Port: 80"