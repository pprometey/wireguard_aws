#!/bin/bash
cd /opt/efs/wireguard
aws s3 sync s3://trafilea-network/wireguard/ .

# We read from the input parameter the name of the client
if [ -z "$1" ]
  then 
    read -p "Enter VPN user name: " USERNAME
    if [ -z $USERNAME ]
      then
      echo "[#]Empty VPN user name. Exit"
      exit 1;
    fi
  else USERNAME=$1
fi

if [ -d "/opt/efs/wireguard/clients" ] && [ -d "/opt/efs/wireguard/clients/$USERNAME" ]
  then 
    echo "[#] User already exist. Exiting"
    exit 1;
  else echo "[#] Creating new user"
fi

read DNS < ./dns.var
read ENDPOINT < ./endpoint.var
read VPN_SUBNET < ./vpn_subnet.var
read ALLOWED_IP < ./allowed_ips.var
read SERVER_PUBLIC_KEY < /opt/efs/wireguard/server_public.key
PRESHARED_KEY="_preshared.key"
PRIV_KEY="_private.key"
PUB_KEY="_public.key"

# Go to the wireguard directory and create a directory structure in which we will store client configuration files
mkdir -p ./clients
cd ./clients
mkdir -p ./$USERNAME
cd ./$USERNAME
umask 077

CLIENT_PRESHARED_KEY=$( wg genpsk )
CLIENT_PRIVKEY=$( wg genkey )
CLIENT_PUBLIC_KEY=$( echo $CLIENT_PRIVKEY | wg pubkey )

echo $CLIENT_PRESHARED_KEY > ./"PRESHARED_KEY_$USERNAME"
echo $CLIENT_PRIVKEY > ./"PRIV_KEY_$USERNAME"
echo $CLIENT_PUBLIC_KEY > ./"PUB_KEY_$USERNAME"

# We get the following client IP address
FILE_LAST_IP=/opt/efs/wireguard/last_used_ip.var
if [ -f "$FILE_LAST_IP" ]; then
    read OCTET_IP < $FILE_LAST_IP
else 
    echo 1 > $FILE_LAST_IP
    read OCTET_IP < $FILE_LAST_IP
fi
OCTET_IP=$(($OCTET_IP+1))
echo $OCTET_IP > /opt/efs/wireguard/last_used_ip.var
CLIENT_IP="$VPN_SUBNET$OCTET_IP/32"

# Create a blank configuration file client 
cat > ./$USERNAME.conf << EOF
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
cat >> /opt/efs/wireguard/wireguard.conf << EOF

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
PresharedKey = $CLIENT_PRESHARED_KEY
AllowedIPs = $CLIENT_IP
EOF

# Restart Wireguard
# TODO: All should restart here
systemctl stop wg-quick@wg0
cp /opt/efs/wireguard/wireguard.conf /etc/wireguard/wg0.conf
systemctl start wg-quick@wg0

cd /opt/efs/wireguard
aws s3 sync . s3://trafilea-network/wireguard/

# Show QR config to display
# qrencode -t ansiutf8 < ./$USERNAME.conf

# Show config file
# echo "# Display $USERNAME.conf"
# cat ./clients/$USERNAME/$USERNAME.conf