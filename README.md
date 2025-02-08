# Network Shaping Script

## Description
A script for network shaping using `iptables` and `Traffic Control`. It configures the firewall and manages network traffic distribution:  
- 70% for HTTP/HTTPS  
- 25% for SMTP/POP3/IMAP  
- 5% for ICMP  

## Requirements
- Linux with `iptables` and `tc` installed 
- Two (virtual) machines: Server and Client
- Root privileges  

## How to Run
1. Open yaml file on server:
  ```sh
  sudo nano /etc/netplan/*.yaml
  ```
2. Copy `server.yaml` configurations.
3. Apply changes:
  ```sh
  sudo netplan apply
  ```
4. Do the same thing on Client using `client.yaml` file.
5. Copy the `scriptTC.sh` file to the Server.
6. Run the script with root privileges:
  ```sh
  sudo ./scriptTC.sh
  ```
