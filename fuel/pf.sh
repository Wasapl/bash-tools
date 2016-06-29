#!/bin/bash
EXT_IP="172.18.92.146" # Он всё равно чаще всего один и тот же.
FAKE_PORT=65443  # Вначале передаём скрипту "неправильный" порт на внешнем интерфейсе,
LAN_IP=172.16.0.4     # затем - локальный адрес сервера
SRV_PORT=443   # и в конце - реальный порт для подключения к серверу

# Здесь желательно сделать проверку ввода данных, потому что операции достаточно серьёзные.

#iptables -t nat -A PREROUTING -p tcp -m tcp -d 172.18.82.136 --dport 65443 -j DNAT --to-destination 172.16.0.2:443
iptables -t nat -A PREROUTING -d $EXT_IP -p tcp -m tcp --dport $FAKE_PORT -j DNAT --to-destination $LAN_IP:$SRV_PORT
iptables -I FORWARD 1 -d $LAN_IP -p tcp -m tcp --dport $SRV_PORT -j ACCEPT
#iptables -I FORWARD 1 -p tcp -d 172.16.0.2 --dport 443 -j ACCEPT

