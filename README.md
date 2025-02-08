# Network Shaping Script

## Description
A script for network shaping using `iptables` and `Traffic Control`. It configures the firewall and manages network traffic distribution:  
- 70% for HTTP/HTTPS  
- 25% for SMTP/POP3/IMAP  
- 5% for ICMP  

## Requirements
- Linux with `iptables` and `tc` installed 
- Two (visrtual) machines: Server and Client
- Root privileges  

## How to Run
1. Change .yaml file on Server:
  1.1. Open yaml file:
  ```sh
  sudo nano /etc/netplan/*.yaml
  ```
  1.2. Copy `server.yaml` configurations.
  1.3. Apply changes:
  ```sh
  sudo netplan apply
  ```
2. Change .yaml file on Client:
2.1. Open yaml file:
  ```sh
  sudo nano /etc/netplan/*.yaml
  ```
  2.2. Copy `client.yaml` configurations.
  2.3. Apply changes:
  ```sh
  sudo netplan apply
  ```
3. Copy the `scriptTC.sh` file to the Server.
4. Run the script with root privileges:
  ```sh
  sudo ./scriptTC.sh
  ```
