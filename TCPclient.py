#!/usr/bin/env python3

import socket, sys, subprocess, json, time

HOST_IP = '192.168.1.21'  # The server's hostname or IP address
SERVER_PORT = 3333        # The port used by the server

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


class TCPclient():
    def __init__(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


    def connect(self):
        self.sock.connect((HOST_IP, SERVER_PORT))


    def getFileInfo(self, filePath):
        fileInfo = {'name': '',
                    'md5sum': ''}

        filename = filePath.strip().split('/')[-1]
        cmd = 'md5sum ' + filePath + ' | cut -d\' \' -f1'
        md5 = subprocess.run(cmd,shell=True, check=True, stdout=subprocess.PIPE).stdout.decode().strip()

        fileInfo['name'] = filename
        fileInfo['md5sum'] = md5

        return fileInfo


    def sendData (self, data):
        """
        Send data to the client using socket 'sock'
        """
        try :
            self.sock.sendall(data)
        except socket.error as e :
            print("Error sending data: %s" %e)
            sys.exit(1)

    def recvData (self, size=1024):
        """
        Receive data of size 'size' from the client using socket 'sock'
        """
        try :
            data = self.sock.recv(size)
        except socket.error as e :
            print("Error receiving data: %s" %e)
            sys.exit(1)

        return data

    def sendFile (self, fileInfo):
        """
        Function to read and send the file 'filename'
        to the client using the socket 'sock'
        """
        try :
            fd = open(fileInfo['name'], 'rb')
            self.sendData(MODE_FILE.encode())  # Tell the server we want to send a file
            if self.recvData().decode() == MODE_FILE_OK:  # The server is in file reception mode
                print("Server in file reception mode")
                self.sendData(START_SEND_DATA.encode())  # Tell the server we want to send data
                if self.recvData().decode() == START_SEND_DATA_OK: # The server is ready to receive data
                    print("Server Ready to receive data")
                    self.sendData(json.dumps(fileInfo_dict).encode())  # Send data
                    if self.recvData().decode() == SEND_DATA_SUCCESS:
                        print("File info received by the server")
                    else:
                        print("ERROR, data has not been received properly")
                        return
                else:
                    print("ERROR, the server cannot receive data at the moment")
                    return
            else:
                print ("ERROR, cannot send file, check with server")
                return
        except IOError :
            print("---File Not Present---")
            return

        print('Sending file: ' + fileInfo['name'])
        read_data = fd.read(4096)
        while (read_data ):
            #print('sending data...')
            self.sendData(read_data)
            #print('Sent ',repr(read_data))
            ack = self.recvData()
            if ack.decode() == SEND_DATA_FAIL:
                print("ERROR, FILE TRANSFERT FAILED")
                return
            else:
                print("Transfert...")
            read_data = fd.read(4096)
        fd.close()

        self.sendData(SEND_TRANSFERT_END.encode())
        if self.recvData().decode() == SEND_TRANSFERT_SUCCESS:
            print("SUCCESS, File transfered successfuly")
        else:
            print("ERROR, File transfer failed")

    def close(self):
        self.sock.close()


tcp_client = TCPclient()

try:
    # Establish connection to TCP server and exchange data
    tcp_client.connect()
    # tcp_client.sendData("Hello World".encode())
    print("Extracting file info...")
    fileInfo_dict = tcp_client.getFileInfo('test.txt')
    tcp_client.sendFile(fileInfo_dict)

finally:
    tcp_client.close()
