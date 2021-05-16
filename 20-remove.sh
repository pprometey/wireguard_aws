echo "# Removing"

wg-quick down wg0
systemctl stop wg-quick@wg0
systemctl disable wg-quick@wg0

apt autoremove -y wireguard wireguard-dkms wireguard-tools
#yes | apt autoremove software-properties-common
apt update

rm -rf /etc/wireguard

echo "# Removed"
