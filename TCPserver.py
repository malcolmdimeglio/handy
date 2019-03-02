#!/usr/bin/env python3

from pathlib import Path
import socketserver, subprocess, json

HOST_IP = '192.168.1.21'  # The server's hostname or IP address
SERVER_PORT = 3333        # The port used by the server
HOME = str(Path.home()) + '/'

MODE_LISTEN="s0"

MODE_TEXT="s1"
MODE_TEXT_OK="s11"
MODE_TEXT_NOK="s12"

MODE_FILE="s2"
MODE_FILE_OK="s21"
MODE_FILE_NOK="s22"

START_SEND_DATA="s3"
START_SEND_DATA_OK="s30"
SEND_DATA_SUCCESS="s31"
SEND_DATA_FAIL="s32"

SEND_TRANSFERT_END="s4"
SEND_TRANSFERT_SUCCESS="s41"
SEND_TRANSFERT_FAIL="s42"



class Handler_TCPServer(socketserver.BaseRequestHandler):
    """
    The TCP Server class for demonstration.

    Note: We need to implement the Handle method to exchange data
    with TCP client.

    """

    def fileRecv (self, fileInfo):
        """
        Function to receive the file 'filename' from the server
        using the socket 'sock' and write in on the client side
        """
        print("---File Present---")

        fileInfo = json.loads(fileInfo)
        # Read the md5sum from the file to receive
        md5sumRemote = fileInfo["md5sum"]
        filename = fileInfo["name"]

        print("filename received: " + filename)
        print("md5sum received: " + md5sumRemote)

        destination_file = HOME + 'received_' + filename

        with open(destination_file, 'wb') as f:
            print('Destination file created')
            print('Receiving Data...')
            while True:
                #print('receiving data...')
                data = self.request.recv(4096)
                #print("data = %s", (data))

                if not data or data == 'EOF' or data.decode() == SEND_TRANSFERT_END:
                    break

                # write data to a file
                f.write(data)
                self.request.send(SEND_DATA_SUCCESS.encode())
        f.close()

        # Get md5sum from the received file
        cmd = 'md5sum ' + destination_file + ' | cut -d\' \' -f1'
        md5sumLocal = subprocess.run(cmd,shell=True, check=True, stdout=subprocess.PIPE).stdout.decode().strip()

        if md5sumLocal == md5sumRemote:
            print("SUCCESS: File transfered: " + filename)
            self.request.send(SEND_TRANSFERT_SUCCESS.encode())
        else:
            print('File ' + filename + ' is corrupted')
            print('Remote: ' + md5sumRemote)
            print('Local:  ' + md5sumLocal)
            self.request.send(SEND_TRANSFERT_FAIL.encode())

    def handle(self):
        # self.request - TCP socket connected to the client
        self.data = self.request.recv(1024)

        if self.data.decode() == MODE_FILE:
            self.request.sendall(MODE_FILE_OK.encode())
            print("Accepting File reception mode")

            self.data = self.request.recv(1024)
            if self.data.decode() == START_SEND_DATA:
                self.request.sendall(START_SEND_DATA_OK.encode())
                print("Accepting incoming data")

                fileInfo = self.request.recv(1024)
                self.request.sendall(SEND_DATA_SUCCESS.encode())

                self.fileRecv(fileInfo.decode())
        elif self.data.decode() == MODE_TEXT or self.data.decode() == START_SEND_DATA:
            # print("---File Not Present---")
            print("{} sent: {}".format(self.client_address[0], self.data.decode()))
        else:
            print("ERROR, Unsuported transfert mode")

        # just send back ACK for data arrival confirmation
        self.request.sendall("Server is listening...".encode())
        print("Listening...")

if __name__ == "__main__":
    # Init the TCP server object, bind it to the localhost on 9999 port
    tcp_server = socketserver.TCPServer((HOST_IP, SERVER_PORT), Handler_TCPServer)

    # Activate the TCP server.
    # To abort the TCP server, press Ctrl-C.
    print("Listening...")
    tcp_server.serve_forever()
