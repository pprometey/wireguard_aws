echo "# Reseting..."

cd /etc/wireguard

# Очистка пользовательских данных
rm -rf ./clients

# Обнуление счетчика IP-адресов
echo "1" > last_used_ip.var

# Сброс серверверного файла конфигураций до дефолтного
cp -f wg0.conf.def wg0.conf

systemctl stop wg-quick@wg0
wg-quick down wg0

echo "# Reseted"