#!/bin/bash

#zmienne
INTERFACE_IN="enp0s8" 
INTERFACE_OUT="enp0s3" 
RATE="100mbit"
HTTP_RATE="70mbit"
MAIL_RATE="25mbit"
ICMP_RATE="5mbit"

#czyszczenie poprzednich ustawien
QDISC_IN=$(tc qdisc show dev $INTERFACE_IN | grep "root") 
QDISC_OUT=$(tc qdisc show dev $INTERFACE_OUT | grep "root")
if [ -n "QDISC_IN" ]; then
tc qdisc del dev $INTERFACE_IN root
fi
if [ -n "QDISC_OUT" ]; then
tc qdisc del dev $INTERFACE_OUT root
fi
iptables -F
iptables -F -t nat
iptables -X -t nat
iptables -F -t filter 
iptables -X -t filter

#konfiguracja firewall 
iptables -P FORWARD ACCEPT 
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED, RELATED -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -A FORWARD -i enp0s3 -s 10.10.10.0/24 -d 0/0 -j ACCEPT 
iptables -A FORWARD -i enp0s8 -s 0/0 -d 10.10.10.0/24 -j ACCEPT 
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -d 0/0 -j MASQUERADE 
iptables -t nat -A POSTROUTING -s 0/0 -d 10.10.10.0/24 -j MASQUERADE

#konfigurajca interfejsu wewnetrznego
tc qdisc add dev $INTERFACE_IN root handle 1: htb default 30
tc class add dev $INTERFACE_IN parent 1: classid 1:1 htb rate $RATE

tc class add dev $INTERFACE_IN parent 1:1 classid 1:10 htb rate $HTTP_RATE
tc class add dev $INTERFACE_IN parent 1:1 classid 1:20 htb rate $MAIL_RATE 
tc class add dev $INTERFACE_IN parent 1:1 classid 1:30 htb rate $ICMP_RATE

tc qdisc add dev $INTERFACE_IN parent 1:10 handle 10: sfq perturb 10 
tc qdisc add dev $INTERFACE_IN parent 1:20 handle 20: sfq perturb 10 
tc qdisc add dev $INTERFACE_IN parent 1:30 handle 30: sfq perturb 10

#klasa 1
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 80 0xffff flowid 1:10
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 443 0xffff flowid 1:10
#klasa 2
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 25 0xffff flowid 1:20 
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 110 0xffff flowid 1:20 
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 143 0xffff flowid 1:20
#klasa 3
tc filter add dev $INTERFACE_IN protocol ip parent 1:0 prio 1 u32 match ip sport 995 0xffff flowid 1:30

#kofiguracja interfejsu zewnetrznego
tc qdisc add dev $INTERFACE_OUT root handle 1: htb default 30

tc class add dev $INTERFACE_OUT parent 1: classid 1:1 htb rate $RATE
tc class add dev $INTERFACE_OUT parent 1:1 classid 1:10 htb rate $HTTP_RATE 
tc class add dev $INTERFACE_OUT parent 1:1 classid 1:20 htb rate $MAIL_RATE 
tc class add dev $INTERFACE_OUT parent 1:1 classid 1:30 htb rate $ICMP_RATE

tc qdisc add dev $INTERFACE_OUT parent 1:10 handle 10: sfq perturb 10 
tc qdisc add dev $INTERFACE_OUT parent 1:20 handle 20: sfq perturb 10 
tc qdisc add dev $INTERFACE_OUT parent 1:30 handle 30: sfq perturb 10

#klasa 1
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip dport 80 0xffff flowid 1:10
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip dport 443 0xffff flowid 1:10
#klasa 2
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip sport 25 0xffff flowid 1:20
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip sport 110 0xffff flowid 1:20
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip sport 143 0xffff flowid 1:20
#klasa 3
tc filter add dev $INTERFACE_OUT protocol ip parent 1:0 prio 1 u32 match ip dport 995 0xffff flowid 1:30
