import socket  
  
address = ('127.0.0.1', 8000)  
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  
  
while True:  
    msg = raw_input()  
    if not msg:  
        break  
    s.sendto(msg, address)  
  
s.close()
