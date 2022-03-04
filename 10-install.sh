#!/bin/bash

# work direcrory
WORK_DIR=/etc/wireguard

# установка wireguard
apt update && \
apt install -y wireguard-dkms wireguard-tools qrencode


# разрешить перенаправлени пакетов
IP_FORWARD="net.ipv4.ip_forward=1"
FORWARD_FILE=/etc/sysctl.d/99-ip_forward.conf
echo $IP_FORWARD > $FORWARD_FILE && sysctl -p $FORWARD_FILE

# перейти в рабочую директорию
cd ${WORK_DIR}

# change default umask
umask 077

# generate server keys


if [[ -e server.pub && server.key ]]
  then echo "ключи есть"	
  else
    SERVER_PRIVKEY=$( wg genkey )
    SERVER_PUBKEY=$( echo $SERVER_PRIVKEY | wg pubkey )
    echo $SERVER_PUBKEY > ./server.pub
    echo $SERVER_PRIVKEY > ./server.key
fi


#set endpoit — wan server ip's
WAN_IP=$(curl 2ip.ru)

read -p "Enter the endpoint (external ip and port) in format [ipv4:port]. ([ENTER] set $WAN_IP:51820): " ENDPOINT
if [ -z $ENDPOINT ]
  then echo "${WAN_IP}:51820" | tee ./endpoint.var; 
  else echo $ENDPOINT > ./endpoint.var
fi

# set vpn-server vpn address
if [ -z "$1" ]
  then 
    read -p "Enter the server address in the VPN subnet (CIDR format), [ENTER] set to default: 10.100.200.1: " SERVER_IP
    if [ -z $SERVER_IP ]
      then SERVER_IP="10.8.8.1"
    fi
  else SERVER_IP=$1
fi

# set vpn-server subnet
echo $SERVER_IP | grep -o -E '([0-9]+\.){3}' > ./vpn_subnet.var

read -p "Enter the ip address of the server DNS (CIDR format), [ENTER] set to default: 9.9.9.9): " DNS
if [ -z $DNS ]
then DNS="9.9.9.9"
fi
echo $DNS > ./dns.var

echo 1 > ./last_used_ip.var

# set wan interface
./detect_wan.sh

cat ./endpoint.var | sed -e "s/:/ /" | while read SERVER_EXTERNAL_IP SERVER_EXTERNAL_PORT
do
cat > ./wg0.conf.def << EOF
[Interface]
Address = $SERVER_IP
SaveConfig = false
PrivateKey = $SERVER_PRIVKEY
ListenPort = $SERVER_EXTERNAL_PORT
#PostUp = wg set %i private-key <(pass )
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $WAN_INTERFACE_NAME -j MASQUERADE;
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $WAN_INTERFACE_NAME -j MASQUERADE;
EOF
done

cp -f ./wg0.conf.def ./wg0.conf

systemctl enable wg-quick@wg0
