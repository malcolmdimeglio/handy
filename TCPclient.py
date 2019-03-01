#!/usr/bin/env python3

import socket

HOST_IP = '127.0.0.1'  # The server's hostname or IP address
SERVER_PORT = 3333        # The port used by the server

tcp_client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    # Establish connection to TCP server and exchange data
    tcp_client.connect((HOST_IP, SERVER_PORT))
    message='Hello, world'
    tcp_client.sendall(message.encode())

    # Read data from the TCP server and close the connection
    received = tcp_client.recv(1024).decode()
finally:
    tcp_client.close()

print(received)
