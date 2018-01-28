import socket
import smsandcall
# Address
HOST = '127.0.0.1'
PORT = 8000

# Configure socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))

while True:  
    data, addr = s.recvfrom(2048)  
    if not data:  
        print ("client has exist")  
        break  
    str1 = str(data, encoding = "utf8")
    str2 = str1.split('|')
    print ("received:", str2[0], "and", str2[1], "from", addr)
    smsandcall.messagesend(str2[0], str2[1])    
  
s.close() 

