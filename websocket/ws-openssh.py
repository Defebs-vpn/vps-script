#!/usr/bin/python3
# OpenSSH WebSocket
# Created by: Defebs-vpn
# Created at: 2025-02-07 14:56:51

import socket
import threading
import ssl
import logging
import time
import sys
import json
from websockets.server import serve
import asyncio

# Configuration
LISTENING_PORT = 80
SSH_PORT = 22
MAX_CONNECTIONS = 1000
BUFFER_SIZE = 65535

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/ws-openssh.log'),
        logging.StreamHandler()
    ]
)

class WSProxy:
    def __init__(self):
        self.active_connections = 0
        self.started_time = time.time()
        
    async def handle_connection(self, websocket, path):
        try:
            self.active_connections += 1
            logging.info(f"New connection from {websocket.remote_address}. Total: {self.active_connections}")
            
            ssh_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ssh_sock.connect(('127.0.0.1', SSH_PORT))
            
            async def forward_ws_to_ssh():
                try:
                    while True:
                        data = await websocket.recv()
                        if not data:
                            break
                        ssh_sock.send(data)
                except:
                    pass
                
            async def forward_ssh_to_ws():
                try:
                    while True:
                        data = ssh_sock.recv(BUFFER_SIZE)
                        if not data:
                            break
                        await websocket.send(data)
                except:
                    pass
                
            await asyncio.gather(
                forward_ws_to_ssh(),
                forward_ssh_to_ws()
            )
            
        except Exception as e:
            logging.error(f"Error: {str(e)}")
            
        finally:
            ssh_sock.close()
            self.active_connections -= 1
            logging.info(f"Connection closed. Total: {self.active_connections}")
            
    async def start_server(self):
        async with serve(
            self.handle_connection,
            "0.0.0.0",
            LISTENING_PORT,
            max_size=None,
            read_limit=2**20,
            write_limit=2**20,
        ) as server:
            logging.info(f"WebSocket server started on port {LISTENING_PORT}")
            await asyncio.Future()  # run forever
            
    def get_stats(self):
        return {
            "active_connections": self.active_connections,
            "uptime": int(time.time() - self.started_time),
            "port": LISTENING_PORT,
            "max_connections": MAX_CONNECTIONS
        }

if __name__ == "__main__":
    proxy = WSProxy()
    try:
        asyncio.run(proxy.start_server())
    except KeyboardInterrupt:
        logging.info("Server shutting down...")
    except Exception as e:
        logging.error(f"Fatal error: {str(e)}")
        sys.exit(1)
class WSProxyStats:
    def __init__(self):
        self.connections = {}
        self.total_bytes_in = 0
        self.total_bytes_out = 0
        self.start_time = time.time()

    def add_connection(self, client_addr):
        self.connections[client_addr] = {
            'connected_at': time.time(),
            'bytes_in': 0,
            'bytes_out': 0
        }

    def remove_connection(self, client_addr):
        if client_addr in self.connections:
            del self.connections[client_addr]

    def update_bytes(self, client_addr, bytes_in=0, bytes_out=0):
        if client_addr in self.connections:
            self.connections[client_addr]['bytes_in'] += bytes_in
            self.connections[client_addr]['bytes_out'] += bytes_out
            self.total_bytes_in += bytes_in
            self.total_bytes_out += bytes_out

    def get_stats(self):
        return {
            'uptime': int(time.time() - self.start_time),
            'total_connections': len(self.connections),
            'total_bytes_in': self.total_bytes_in,
            'total_bytes_out': self.total_bytes_out,
            'connections': self.connections
        }

class WSMonitor:
    def __init__(self, proxy):
        self.proxy = proxy
        self.stats = WSProxyStats()

    async def start_monitoring(self):
        while True:
            stats = self.stats.get_stats()
            logging.info(f"WebSocket Stats: {json.dumps(stats, indent=2)}")
            await asyncio.sleep(300)  # Monitor every 5 minutes

    async def handle_admin(self, websocket, path):
        try:
            while True:
                stats = self.stats.get_stats()
                await websocket.send(json.dumps(stats))
                await asyncio.sleep(1)
        except Exception as e:
            logging.error(f"Admin interface error: {str(e)}")

if __name__ == "__main__":
    proxy = WSProxy()
    monitor = WSMonitor(proxy)
    
    async def main():
        await asyncio.gather(
            proxy.start_server(),
            monitor.start_monitoring()
        )
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        logging.info("Server shutting down...")
    except Exception as e:
        logging.error(f"Fatal error: {str(e)}")
        sys.exit(1)