#!/bin/bash

# work direcrory
WORK_DIR=/etc/wireguard

# We read from the input parameter the name of the client
if [ -z "$1" ]
  then 
    read -p "Enter VPN user email: " EMAIL
    if [ -z $EMAIL ]
      then
      echo "[#]Empty VPN user email. Exit"
      exit 1;
    fi
  else EMAIL=$1
fi
userName=$(echo $EMAIL | awk -F "@" '{print $1}')
echo "Username is $userName"

cd $WORK_DIR

read DNS < ./dns.var
read ENDPOINT < ./endpoint.var
read VPN_SUBNET < ./vpn_subnet.var
PRESHARED_KEY=".preshared"
PRIV_KEY=".key"
PUB_KEY=".pub"
ALLOWED_IP="0.0.0.0/0"

# Go to the wireguard directory and create a directory structure in which we will store client configuration files
if [ -d ./clients/${userName} ]
  then 
    cd ./clients/${userName}
  else mkdir -p ./clients/${userName} && \
      cd ./clients/${userName} && \
      umask 077
fi


CLIENT_PRESHARED_KEY=$( wg genpsk )
CLIENT_PRIVKEY=$( wg genkey )
CLIENT_PUBLIC_KEY=$( echo $CLIENT_PRIVKEY | wg pubkey )

echo ${CLIENT_PRESHARED_KEY} > ./"${userName}${PRESHARED_KEY}"
echo ${CLIENT_PRIVKEY} > ./"${userName}${PRIV_KEY}"
echo ${CLIENT_PUBLIC_KEY} > ./"${userName}${PUB_KEY}"

read SERVER_PUBLIC_KEY < /etc/wireguard/server.pub

# We get the following client IP address
read OCTET_IP < /etc/wireguard/last_used_ip.var
if
	[[ $OCTET_IP -ge 254 ]]; then
	echo "Пул исчерпан!"
	exit 1;
fi

OCTET_IP=$((OCTET_IP+1))
echo $OCTET_IP > /etc/wireguard/last_used_ip.var

CLIENT_IP="$VPN_SUBNET$OCTET_IP/32"

# Create a blank configuration file client 
cat > /etc/wireguard/clients/$userName/$userName.conf << EOF
[Interface]
PrivateKey = $CLIENT_PRIVKEY
Address = $CLIENT_IP
DNS = $DNS

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
AllowedIPs = $ALLOWED_IP
Endpoint = $ENDPOINT
PersistentKeepalive=25
EOF

# Add new client data to the Wireguard configuration file
cat >> /etc/wireguard/wg0.conf << _EOF_

[Peer] # $EMAIL
PublicKey = $CLIENT_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
AllowedIPs = $CLIENT_IP
_EOF_

# Restart Wireguard
systemctl restart wg-quick@wg0

# Show QR config to display
qrencode -t ansiutf8 < ./$userName.conf

# Show config file
echo "# Display $userName.conf"
cat ./$userName.conf

# Save QR config to png file
qrencode -t png -o ./$userName.png < ./$userName.conf
