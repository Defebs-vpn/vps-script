#!/usr/bin/python3
# Enhanced WebSocket Proxy
# By: Defebs-vpn
# Current Date: 2025-02-07 15:30:12

import socket
import threading
import ssl
import logging
import time
import sys
import json
import asyncio
import websockets
import argparse
from datetime import datetime

# Configuration
DEFAULT_CONFIG = {
    'listen_port': 80,
    'ssh_port': 22,
    'max_connections': 1000,
    'buffer_size': 65535,
    'ssl_cert': '/etc/xray/xray.crt',
    'ssl_key': '/etc/xray/xray.key',
    'log_file': '/var/log/ws-epro.log'
}

# Setup Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(DEFAULT_CONFIG['log_file']),
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
    def __init__(self, config=DEFAULT_CONFIG):
        self.config = config
        self.connections = {}
        self.stats = {
            'total_connections': 0,
            'active_connections': 0,
            'total_bytes_in': 0,
            'total_bytes_out': 0,
            'start_time': time.time()
        }
        
    async def handle_tunnel(self, websocket, path):
        client_address = websocket.remote_address
        connection_id = f"{client_address[0]}:{client_address[1]}"
        
        try:
            # Create SSH connection
            ssh_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            ssh_sock.connect(('127.0.0.1', self.config['ssh_port']))
            
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
                        data = ssh_sock.recv(self.config['buffer_size'])
                        if not data:
                            break
                        await websocket.send(data)
                        self.connections[connection_id].update(bytes_out=len(data))
                        self.stats['total_bytes_out'] += len(data)
                except:
                    pass
                
            # Handle bidirectional traffic
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
        ssl_context = None
        if 'ssl_cert' in self.config and 'ssl_key' in self.config:
            ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
            ssl_context.load_cert_chain(
                self.config['ssl_cert'],
                self.config['ssl_key']
            )
        
        async with websockets.serve(
            self.handle_tunnel,
            "0.0.0.0",
            self.config['listen_port'],
            ssl=ssl_context,
            max_size=None,
            read_limit=2**20,
            write_limit=2**20
        ) as server:
            logging.info(f"WebSocket server started on port {self.config['listen_port']}")
            await self.start_monitoring()
    
    async def start_monitoring(self):
        while True:
            try:
                # Calculate statistics
                uptime = time.time() - self.stats['start_time']
                active_conn = self.stats['active_connections']
                total_conn = self.stats['total_connections']
                bytes_in_mb = self.stats['total_bytes_in'] / (1024 * 1024)
                bytes_out_mb = self.stats['total_bytes_out'] / (1024 * 1024)
                
                # Log statistics
                logging.info(f"""
WebSocket Server Statistics:
- Uptime: {int(uptime)} seconds
- Active Connections: {active_conn}
- Total Connections: {total_conn}
- Total Data In: {bytes_in_mb:.2f} MB
- Total Data Out: {bytes_out_mb:.2f} MB
""")
                
                # Check for idle connections
                current_time = time.time()
                for conn_id, stats in list(self.connections.items()):
                    idle_time = current_time - stats.last_activity
                    if idle_time > 300:  # 5 minutes timeout
                        logging.warning(f"Closing idle connection: {conn_id}")
                        del self.connections[conn_id]
                        self.stats['active_connections'] -= 1
                
                await asyncio.sleep(60)  # Update every minute
                
            except Exception as e:
                logging.error(f"Monitoring error: {str(e)}")
                await asyncio.sleep(5)

    def get_connection_info(self, connection_id):
        if connection_id in self.connections:
            stats = self.connections[connection_id]
            return {
                'connected_at': datetime.fromtimestamp(stats.connected_at).strftime('%Y-%m-%d %H:%M:%S'),
                'last_activity': datetime.fromtimestamp(stats.last_activity).strftime('%Y-%m-%d %H:%M:%S'),
                'bytes_in': stats.bytes_in,
                'bytes_out': stats.bytes_out,
                'idle_time': int(time.time() - stats.last_activity)
            }
        return None

    def save_statistics(self):
        try:
            stats_file = '/var/log/ws-stats.json'
            with open(stats_file, 'w') as f:
                json.dump({
                    'stats': self.stats,
                    'connections': {
                        conn_id: self.get_connection_info(conn_id)
                        for conn_id in self.connections
                    }
                }, f, indent=2)
        except Exception as e:
            logging.error(f"Error saving statistics: {str(e)}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='WebSocket Proxy Server')
    parser.add_argument('--port', type=int, default=DEFAULT_CONFIG['listen_port'],
                      help='Port to listen on')
    parser.add_argument('--ssh-port', type=int, default=DEFAULT_CONFIG['ssh_port'],
                      help='SSH server port')
    parser.add_argument('--ssl', action='store_true',
                      help='Enable SSL/TLS')
    args = parser.parse_args()

    config = DEFAULT_CONFIG.copy()
    config['listen_port'] = args.port
    config['ssh_port'] = args.ssh_port
    
    if args.ssl and not (os.path.exists(config['ssl_cert']) and 
                        os.path.exists(config['ssl_key'])):
        logging.error("SSL certificates not found!")
        sys.exit(1)

    proxy = WebSocketProxy(config)
    
    try:
        asyncio.run(proxy.start_server())
    except KeyboardInterrupt:
        logging.info("Server shutting down...")
        proxy.save_statistics()
    except Exception as e:
        logging.error(f"Fatal error: {str(e)}")
        proxy.save_statistics()
        sys.exit(1)