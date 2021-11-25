#!/bin/bash
cd /opt/efs/wireguard
aws s3 cp s3://trafilea-network/wireguard/ . --recursive

systemctl stop wg-quick@wg0
cp /opt/efs/wireguard/wireguard.conf /etc/wireguard/wg0.conf
systemctl start wg-quick@wg0
