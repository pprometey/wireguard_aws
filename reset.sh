echo "# Reseting..."

cd /etc/wireguard

# Delete the folder with customer data
rm -rf ./clients

# Zero IP counter
echo "1" > last_used_ip.var

# Resetting the server configuration template to default settings
cp -f wg0.conf.def wg0.conf

echo "# Reseted"

