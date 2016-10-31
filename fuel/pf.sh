#!/bin/bash

pf()
{
EXT_IP=$1 # Он всё равно чаще всего один и тот же.
FAKE_PORT=$2  # Вначале передаём скрипту "неправильный" порт на внешнем интерфейсе,
LAN_IP=$3     # затем - локальный адрес сервера
SRV_PORT=$4   # и в конце - реальный порт для подключения к серверу
INT_IP=$5
# Здесь желательно сделать проверку ввода данных, потому что операции достаточно серьёзные.

#iptables -t nat -A PREROUTING -p tcp -m tcp -d 172.18.82.136 --dport 65443 -j DNAT --to-destination 172.16.0.2:443
iptables -t nat -I PREROUTING 1 -d $EXT_IP -p tcp -m tcp --dport $FAKE_PORT -j DNAT --to-destination $LAN_IP:$SRV_PORT
iptables -t nat -I POSTROUTING 1 -d $LAN_IP -p tcp -m tcp --dport $SRV_PORT -j SNAT --to-source $INT_IP
iptables -t nat -I OUTPUT 1 -d $EXT_IP -p tcp -m tcp --dport $SRV_PORT -j DNAT --to-destination $LAN_IP
iptables -I FORWARD 1 -d $LAN_IP -p tcp -m tcp --dport $SRV_PORT -j ACCEPT
#iptables -I FORWARD 1 -p tcp -d 172.16.0.2 --dport 443 -j ACCEPT

}

pf 172.16.0.4 8081 192.168.0.8 80 192.168.0.4
pf 172.16.0.4 8082 192.168.0.9 80 192.168.0.4
pf 172.16.0.4 8083 192.168.0.6 80 192.168.0.4




