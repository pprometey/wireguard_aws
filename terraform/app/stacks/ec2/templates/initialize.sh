#!/bin/bash -v
sudo chmod o+rw .
apt-get update
apt-get install nfs-common -y
add-apt-repository ppa:wireguard/wireguard -y
apt update
apt install software-properties-common wireguard-dkms wireguard-tools qrencode awscli -y

sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv6.conf.all.forwarding=0
sed -i "s:#net.ipv4.ip_forward=1:net.ipv4.ip_forward=1:" /etc/sysctl.conf

# Mount efs here
mkdir /opt/efs
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/ /opt/efs

if [ ! -d "/opt/efs/wireguard" ]
  then 
    mkdir /opt/efs/wireguard
fi

cd /opt/efs/wireguard

aws s3 cp s3://trafilea-network/wireguard/ . --recursive
chmod +x *.sh

FILE_SV_KEY=./server_private.key
FILE_SV_PKEY=./server_public.key
if [ -f "$FILE_SV_KEY" ]; then
    echo "$FILE_SV_KEY exists."
    read SERVER_PUBKEY < $FILE_SV_PKEY
    read SERVER_PRIVKEY < $FILE_SV_KEY
else 
    echo "$FILE_SV_KEY does not exist."
    SERVER_PRIVKEY=$( wg genkey )
    SERVER_PUBKEY=$( echo $SERVER_PRIVKEY | wg pubkey )
    echo $SERVER_PUBKEY > $FILE_SV_PKEY
    echo $SERVER_PRIVKEY > $FILE_SV_KEY
fi

if [ ! -f "./dns.var" ]; then
    DNS="8.8.8.8"
    echo $DNS > ./dns.var
fi

if [ ! -f "./vpn_subnet.var" ]; then
    VPN_SUBNET="${wg_server_net}"
    echo $VPN_SUBNET > ./vpn_subnet.var
fi

if [ ! -f "./allowed_ips.var" ]; then
    ALLOWED_IP="${allowed_ips}"
    echo $ALLOWED_IP > ./allowed_ips.var
fi

if [ ! -f "./endpoint.var" ]; then
    ENDPOINT="${public_dns}:${wg_server_port}"
    echo $ENDPOINT > ./endpoint.var
fi

FILE_WIREGUARD_CONF=./wireguard.conf
if [ ! -f "$FILE_WIREGUARD_CONF" ]; then
    cat > $FILE_WIREGUARD_CONF <<- EOF
[Interface]
Address = ${wg_server_net}
PrivateKey = $SERVER_PRIVKEY
ListenPort = ${wg_server_port}
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ENI -j MASQUERADE;
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ENI -j MASQUERADE;
EOF
    export ENI=$(ip route get 8.8.8.8 | grep 8.8.8.8 | awk '{print $5}')
    sed -i "s/ENI/$ENI/g" $FILE_WIREGUARD_CONF
fi

cp $FILE_WIREGUARD_CONF /etc/wireguard/wg0.conf
chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*
sysctl -p
systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

until systemctl is-active --quiet wg-quick@wg0.service
do
  sleep 1
done

ufw disable